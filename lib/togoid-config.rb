require 'fileutils'

module TogoID

  class Node
    attr_reader :catalog, :category, :label, :prefix, :regex, :internal_format, :external_format
    def initialize(hash)
      @catalog = hash["catalog"]
      @category = hash["category"]
      @label = hash["label"]
      @prefix = hash["prefix"]
      @regex = hash["regex"]
      @internal_format = hash["internal_format"]
      @external_format = hash["external_format"]
    end
  end

  class Edge
    attr_reader :label, :ns, :prefix, :predicate
    def initialize(hash)
      @label = hash["label"]
      @ns = hash["namespace"]
      @prefix = hash["prefix"]
      @predicate = hash["predicate"]
    end
  end

  class Link
    attr_reader :files, :fwd, :rev
    def initialize(hash)
      @files = ([] << hash["file"]).flatten
      @fwd = Edge.new(hash["forward"]) if hash["forward"]
      @rev = Edge.new(hash["reverse"]) if hash["reverse"]
    end
  end
  
  class Update
    attr_reader :frequency, :method
    def initialize(hash)
      @frequency = hash["frequency"]
      @method = hash["method"]
    end
  end

  class Config
    class NoConfigError < StandardError; end

    attr_reader :source, :target, :link, :update
    def initialize(config_file)
      begin
        config = YAML.load(File.read(config_file))
        @path = File.dirname(config_file)
        @source_ns, @target_ns = File.basename(@path).split('-')
        @link = Link.new(config["link"])
        @update = Update.new(config["update"])
      rescue => error
        puts "Error: #{error.message}"
        exit 1
      end
      load_dataset
      setup_files
    end

    def load_dataset
      begin
        yaml_path = File.join(File.dirname(@path), 'dataset.yaml')
        unless File.exists?(yaml_path)
          yaml_path = './config/dataset.yaml'
        end
        @dataset = YAML.load(File.read(yaml_path))
        raise NoConfigError, @source_ns unless @dataset[@source_ns]
        raise NoConfigError, @target_ns unless @dataset[@target_ns]
        @source = Node.new(@dataset[@source_ns])
        @target = Node.new(@dataset[@target_ns])
      rescue NoConfigError => error
        puts "Error: dataset #{error.message} is not defined in the dataset.yaml file"
        exit 1
      end
    end

    def setup_files
      @tsv_dir = "output/tsv"
      @ttl_dir = "output/ttl"
      @tsv_file = "#{@tsv_dir}/#{@source_ns}-#{@target_ns}.tsv"
      @ttl_file = "#{@ttl_dir}/#{@source_ns}-#{@target_ns}.ttl"
      FileUtils.mkdir_p(@tsv_dir)
      FileUtils.mkdir_p(@ttl_dir)
    end

    def triple(s, p, o)
      [s, p, o, "."].join("\t")
    end

    def prefix
      prefixes = []
      if @link.fwd
        prefixes << triple("@prefix", "#{@link.fwd.ns}:", "<#{@link.fwd.prefix}>")
      end
      if @link.rev and (! @link.fwd or (@link.fwd.ns != @link.rev.ns))
        prefixes << triple("@prefix", "#{@link.rev.ns}:", "<#{@link.rev.prefix}>")
      end
      prefixes << triple("@prefix", "#{@source_ns}:", "<#{@source.prefix}>")
      prefixes << triple("@prefix", "#{@target_ns}:", "<#{@target.prefix}>")
      return prefixes
    end

    def exec_convert
      if File.exists?(@tsv_file)
        File.open(@ttl_file, "w") do |ttl_file|
          ttl_file.puts prefix
          ttl_file.puts
          tsv2ttl(@tsv_file, ttl_file)
        end
      else
        $stderr.puts "TogoID TSV file #{@tsv_file} not found. Run update first."
      end
    end

    def set_predicate(edge)
      if edge
        "#{edge.ns}:#{edge.predicate}"  # e.g., rdfs:seeAlso
      else
        false
      end
    end

    def tsv2ttl(tsv, ttl)
      # To reduce method call
      fwd_predicate = set_predicate(@link.fwd)
      rev_predicate = set_predicate(@link.rev)
      # Should check whether source_id or target_id contains chars that need to be escaped in Turtle
      File.open(tsv).each do |line|
        source_id, target_id, = line.strip.split(/\s+/)
        ttl.puts triple("#{@source_ns}:#{source_id}", "#{fwd_predicate}", "#{@target_ns}:#{target_id}") if fwd_predicate
        ttl.puts triple("#{@target_ns}:#{target_id}", "#{rev_predicate}", "#{@source_ns}:#{source_id}") if rev_predicate
      end
    end

    def exec_update
      ENV['PATH'] = [ File.expand_path('bin'), File.expand_path(@path), ENV['PATH'] ].join(':')
      File.open(@tsv_file, "w") do |tsv_file|
        Dir.chdir(@path) do
          IO.popen(@update.method) do |io|
            while buffer = io.gets
              tsv_file.puts buffer
            end
          end
        end
      end
    end

    def exec_check
      $stderr.puts pp(self)
      $stderr.puts
      puts prefix
      puts
      @link.files.each do |file|
        tsv2ttl("#{@path}/#{file}", $stdout)
      end
    end
  end

end
