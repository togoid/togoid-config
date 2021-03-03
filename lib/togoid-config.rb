require 'fileutils'

module TogoID

  class Node
    attr_reader :catalog, :category, :label, :prefix
    def initialize(hash)
      @catalog = hash["catalog"]
      @category = hash["category"]
      @label = hash["label"]
      @prefix = hash["prefix"]
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
    attr_reader :source, :target, :link, :update
    def initialize(config_file)
      begin
        config = YAML.load(File.read(config_file))
        @path = File.dirname(config_file)
        @source_ns, @target_ns = File.basename(@path).split('-')
        @source = Node.new(config["source"])
        @target = Node.new(config["target"])
        @link = Link.new(config["link"])
        @update = Update.new(config["update"])
      rescue => error
        puts error
        exit 1
      end
      setup_files
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

    def tsv2ttl(tsv, ttl)
      File.open(tsv).each do |line|
        source_id, target_id, = line.strip.split(/\s+/)
        ttl.puts triple("#{@source_ns}:#{source_id}", "#{@link.fwd.ns}:#{@link.fwd.predicate}", "#{@target_ns}:#{target_id}") if @link.fwd
        ttl.puts triple("#{@target_ns}:#{target_id}", "#{@link.rev.ns}:#{@link.rev.predicate}", "#{@source_ns}:#{source_id}") if @link.rev
      end
    end

    def exec_update
      ENV['PATH'] = [ File.expand_path('bin'), File.expand_path(@path), ENV['PATH'] ].join(':')
      File.open(@tsv_file, "w") do |tsv_file|
        Dir.chdir(@path) do
          IO.popen(@update.method) do |io|
            tsv_file.puts io.read
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
