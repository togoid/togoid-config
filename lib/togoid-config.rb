require 'fileutils'
require 'uri'
require 'cgi'

module TogoID

  class Ontology
    def initialize(tio_nt)
      @category_color = CategoryColor.new
      @pred_rdfs_label = {}
      @pred_disp_label = {}
      tio_nt.each_line do |line|
        s, p, o = line.split(/\s+/, 3)
        pred = s.scan(/TIO_\d+/).first
        label = o.scan(/"(.*)"/).first

        # <http://togoid.dbcls.jp/ontology#TIO_000014> <http://www.w3.org/2000/01/rdf-schema#label> "structure has protein domain" .
        if line[/ontology#TIO_/] and line[/rdf-schema#label/] and label
          @pred_rdfs_label[pred] = label.first
        end

        # <http://togoid.dbcls.jp/ontology#TIO_000014> <http://togoid.dbcls.jp/ontology#display_label> "has protein domain" .
        if line[/ontology#TIO_/] and line[/ontology#display_label/] and label
          @pred_disp_label[pred] = label.first
        end
      end
    end

    def predicate(pred)
      "tio:#{pred}"
    end

    def rdfs_label(pred)
      @pred_rdfs_label[pred] || predicate(pred)
    end

    def disp_label(pred)
      @pred_disp_label[pred] || predicate(pred)
    end

    def color(category)
      @category_color[category]
    end

    class CategoryColor
      PALETTE = {
        "Analysis"	=> "#696969",
        "Anatomy"	=> "#006400",
        "CellLine"	=> "#006400",
        "Classification"=> "#696969",
        "Compound"	=> "#A853C6",
        "Domain"	=> "#A2C653",
        "Drug"		=> "#A853C6",
        "Experiment"	=> "#696969",
        "Function"	=> "#696969",
        "Gene"		=> "#53C666",
        "Genome"	=> "#006400",
        "Glycan"	=> "#673AA6",
        "Interaction"	=> "#C65381",
        "Lipid"		=> "#A853C6",
        "Literature"	=> "#696969",
        "Ortholog"	=> "#53C666",
        "Pathway"	=> "#C65381",
        "Phenotype"	=> "#5361c6",
        "Probe"		=> "#53C666",
        "Project"	=> "#696969",
        "Protein"	=> "#A2C653",
        "Proteome"	=> "#006400",
        "Reaction"	=> "#C65381",
        "Sample"	=> "#696969",
        "SequenceRun"	=> "#696969",
        "Structure"	=> "#C68753",
        "Submission"	=> "#696969",
        "Organism"	=> "#006400",
        "Transcript"	=> "#53C666",
        "Variant"	=> "#53C3C6",
      }

      def initialize
        PALETTE.default = "#333333"
      end

      def [](category)
        PALETTE[category]
      end
    end
  end

  # Dataset
  class Node
    attr_reader :catalog, :category, :label, :prefix, :regex, :internal_format, :external_format, :method, :name
    def initialize(name, hash)
      @catalog = hash["catalog"]
      @category = hash["category"]
      @label = hash["label"]
      @prefix = hash["prefix"].find{|x| x["rdf"]}["uri"]
      @regex = hash["regex"]
      @internal_format = hash["internal_format"]
      @external_format = hash["external_format"]
      @method = hash["method"]
      @name = name
    end

    def setup_files
      @ttl_dir = "output/ttl/label"
      @ttl_file = "#{@ttl_dir}/#{@name}.ttl"
      FileUtils.mkdir_p(@ttl_dir)
    end

    def rdfize_id_label
      setup_files
      File.open(@ttl_file, "w") do |ttl_file|
        ttl_file.puts "@prefix #{@name}: <#{@prefix}> ."
        ttl_file.puts "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> ."
        ttl_file.puts "@prefix dcterms: <http://purl.org/dc/terms/> ."
        ttl_file.puts
        Dir.chdir(@ttl_dir) do
          IO.popen(@method) do |io|
            while line = io.gets
              id, label = line.scrub.strip.split("\t")
              sbj = "#{@name}:#{id}"
              id_full = @prefix.gsub(/.+\//, "") + id
              if !label
                $stderr.puts "Warning: Updating #{@ttl_file}: #{id} does not have a label."
                next
              end
              label = label.gsub(/["\\]/, '\\\\\&')

              ttl_file.puts "#{sbj}\tdcterms:identifier\t\"#{id_full}\" ."
              ttl_file.puts "#{sbj}\trdfs:label\t\"#{label}\" ."
            end
          end
        end
      end
    end
  end

  # Predicate (depricated as the TIO ID is introduced since 2022-02-08)
  class Edge
    attr_reader :label, :ns, :prefix, :predicate
    def initialize(hash)
      @label = hash["label"]
      @ns = hash["namespace"]
      @prefix = hash["prefix"]
      @predicate = hash["predicate"]
    end
  end

  # Relation
  class Link
    attr_reader :files, :fwd, :rev
    def initialize(hash)
      @files = ([] << hash["file"]).flatten
=begin 2022-02-08
      @fwd = Edge.new(hash["forward"]) if hash["forward"]
      @rev = Edge.new(hash["reverse"]) if hash["reverse"]
=end
      @fwd = hash["forward"] if hash["forward"]
      @rev = hash["reverse"] if hash["reverse"]
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
        configs = YAML.load(File.read(config_file))
        if configs.is_a? Array
          config = configs[0]
        else
          config = configs
        end
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
        unless File.exist?(yaml_path)
          yaml_path = './config/dataset.yaml'
        end
        @dataset = YAML.load(File.read(yaml_path))
        raise NoConfigError, @source_ns unless @dataset[@source_ns]
        raise NoConfigError, @target_ns unless @dataset[@target_ns]
        @source = Node.new(@source_ns, @dataset[@source_ns])
        @target = Node.new(@target_ns, @dataset[@target_ns])
      rescue NoConfigError => error
        puts "Error: dataset #{error.message} is not defined in the dataset.yaml file"
        exit 1
      end
    end

    def setup_files
      @tsv_dir = "output/tsv"
      @ttl_dir = "output/ttl/relation"
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
=begin 2022-02-08
      if @link.fwd
        prefixes << triple("@prefix", "#{@link.fwd.ns}:", "<#{@link.fwd.prefix}>")
      end
      if @link.rev and (! @link.fwd or (@link.fwd.ns != @link.rev.ns))
        prefixes << triple("@prefix", "#{@link.rev.ns}:", "<#{@link.rev.prefix}>")
      end
=end
      prefixes << triple("@prefix", "tio:", "<http://togoid.dbcls.jp/ontology#>")
      prefixes << triple("@prefix", "#{@source_ns}:", "<#{@source.prefix}>")
      prefixes << triple("@prefix", "#{@target_ns}:", "<#{@target.prefix}>")
      return prefixes
    end

    def exec_convert
      if File.exist?(@tsv_file)
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
=begin 2022-02-08
        "#{edge.ns}:#{edge.predicate}"  # e.g., rdfs:seeAlso
=end
        "tio:#{edge}"
      else
        false
      end
    end

    # Turtle spec: https://www.w3.org/TR/turtle/#sec-grammar-grammar
    #   * PN_LOCAL_ESC ::= '\' ('_' | '~' | '.' | '-' | '!' | '$' | '&' | "'" | '(' | ')' | '*' | '+' | ',' | ';' | '=' | '/' | '?' | '#' | '@' | '%')
    #   * 'a-b_c.d~e!f$g&h,i;j=k#l@m%n/o?p*q+r(s) AFFX-HUMGAPDH/M33197_3_at tX(XXX)D_tRNA'
    #   * => 'a\-b\_c\.d\~e\!f\$g\&h\,i\;j\=k\#l\@m\%n\/o\?p\*q\+r\(s\) AFFX\-HUMGAPDH\/M33197\_3\_at tX\(XXX\)D\_tRNA'
    # See also: http://docs.openlinksw.com/virtuoso/fn_ttlp_mt/
    #SED_PN_LOCAL_ESC = 's/[-_.~!$&,;=#@%\/\?\*\+\(\)]/\\\\&/g'
    #SED_PN_LOCAL_ESC = 's/[~!$&,;=#@%\/\?\*\+\(\)]/\\\\&/g'

    def qname_local_ok?(s)
      return false if s.nil? || s.empty?
      return false if s.end_with?(".")       # 末尾ドットは不可
      return false if s.include?(":")        # ローカル名に ":" は不可
      # 使用禁止文字（空白類, %, /, \, 引用符, 制御/記号の一部）
      return false if s =~ /[[:space:]%\/\\'"<>\#\?\@\`\|\{\}]/
      true
    end

    # IRI 用のパスセグメントエスケープ（space を %20 に）
    def uri_escape_path_segment(seg)
      CGI.escape(seg.to_s).gsub("+", "%20")
    end
    
    # prefix と namespace IRI を渡して、QName か <IRI> を返す
    def node_repr(prefix, ns_iri, local)
      if qname_local_ok?(local)
        "#{prefix}:#{local}"
      else
        "<#{ns_iri}#{uri_escape_path_segment(local)}>"
      end
    end
    
    def tsv2ttl(tsv, ttl)
      fwd_predicate = set_predicate(@link.fwd)
      rev_predicate = set_predicate(@link.rev)
      
      File.readlines(tsv).each do |line|
        source_id, target_id, = line.strip.split(/\s+/)
        
        s = node_repr(@source_ns,  @source.prefix,  source_id)
        t = node_repr(@target_ns,  @target.prefix,  target_id)
        
        ttl.puts triple(s, fwd_predicate, t) if fwd_predicate
        ttl.puts triple(t, rev_predicate, s) if rev_predicate
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
