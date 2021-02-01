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
    attr_reader :ns, :label, :prefix, :predicate, :files
    def initialize(hash)
      @ns = hash["name"]
      @label = hash["label"]
      @prefix = hash["prefix"]
      @predicate = hash["predicate"]
      @files = ([] << hash["file"]).flatten
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
        @link = Edge.new(config["link"])
        if hash = config["reverse_link"]
          @reverse = Edge.new(config["link"].merge(hash))
        end
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
      puts triple("@prefix", "#{@link.ns}:", "<#{@link.prefix}>")
      if @reverse and @link.ns != @reverse.ns
        puts triple("@prefix", "#{@reverse.ns}:", "<#{@reverse.prefix}>")
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
          puts triple("#{@source.ns}:#{source_id}", "#{@link.ns}:#{@link.predicate}", "#{@target.ns}:#{target_id}")
          puts triple("#{@target.ns}:#{target_id}", "#{@reverse.ns}:#{@reverse.predicate}", "#{@source.ns}:#{source_id}") if @reverse
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

