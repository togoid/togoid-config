#!/usr/bin/env ruby

require 'yaml'

module TogoID

  class Node
    attr_reader :ns, :label, :prefix
    def initialize(hash)
      @ns = hash["name"]
      @label = hash["label"]
      @prefix = hash["prefix"]
    end
  end

  class Edge
    attr_reader :ns, :label, :prefix, :predicate
    def initialize(hash)
      @ns = hash["name"]
      @label = hash["label"]
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
    attr_reader :date, :name, :method
    def initialize(hash)
      @date = hash["date"]
      @name = hash["name"]
      @method = hash["method"]
    end

    def run(path)
      Dir.chdir(path) do
        ENV['PATH'] = ".:#{ENV['PATH']}"
        system(@method)
      end
    end
  end

  class Config
    def initialize(config_file, mode)
      begin
        config = YAML.load(File.read(config_file))
        @path = File.dirname(config_file)
        @source = Node.new(config["source"])
        @target = Node.new(config["target"])
        @link = Link.new(config["link"])
        @update = Update.new(config["update"])
      rescue => error
        puts error
        exit 1
      end
      self.send(mode)
    end

    def triple(s, p, o)
      [s, p, o, "."].join("\t")
    end

    def check
      pp self
    end

    def prefix
      if @link.fwd
        puts triple("@prefix", "#{@link.fwd.ns}:", "<#{@link.fwd.prefix}>")
      end
      if @link.rev and (! @link.fwd or (@link.fwd.ns != @link.rev.ns))
        puts triple("@prefix", "#{@link.rev.ns}:", "<#{@link.rev.prefix}>")
      end
      puts triple("@prefix", "#{@source.ns}:", "<#{@source.prefix}>")
      puts triple("@prefix", "#{@target.ns}:", "<#{@target.prefix}>")
      puts
    end

    def convert
      prefix
      @link.files.each do |file|
        File.open("#{@path}/#{file}").each do |line|
          source_id, target_id, = line.strip.split(/\s+/)
          puts triple("#{@source.ns}:#{source_id}", "#{@link.fwd.ns}:#{@link.fwd.predicate}", "#{@target.ns}:#{target_id}") if @link.fwd
          puts triple("#{@target.ns}:#{target_id}", "#{@link.rev.ns}:#{@link.rev.predicate}", "#{@source.ns}:#{source_id}") if @link.rev
        end
      end
    end

    def update
      @update.run(@path)
    end
  end

end


if __FILE__ == $0
  yaml = ARGV.shift             # can be path/to/config.yaml or path/to
  mode = ARGV.shift || "check"  # can be prefix, convert, or update

  if File.directory?(yaml)
    yaml += "/config.yaml"
  end

  TogoID::Config.new(yaml, mode)
end

