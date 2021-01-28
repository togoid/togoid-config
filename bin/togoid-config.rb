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
    attr_reader :ns, :label, :prefix, :predicate, :directed, :files
    def initialize(hash)
      @ns = hash["name"]
      @label = hash["label"]
      @prefix = hash["prefix"]
      @predicate = hash["predicate"]
      @directed = hash["directed"]
      @files = ([] << hash["file"]).flatten
    end
  end

  class Config
    def initialize(config_file)
      if File.exists?(config_file)
        config = YAML.load(File.read(config_file))
        @path = File.dirname(config_file)
        @source = Node.new(config["source"])
        @target = Node.new(config["target"])
        @link = Edge.new(config["link"])
      else
        raise "Config file '#{config_file}' does not exist."
      end
    end

    def triple(s, p, o)
      [s, p, o, "."].join("\t")
    end

    def prefix
      puts triple("@prefix", "#{@link.ns}:", "<#{@link.prefix}>")
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
          puts triple("#{@target.ns}:#{target_id}", "#{@link.ns}:#{@link.predicate}", "#{@source.ns}:#{source_id}") if @link.directed
        end
      end
    end
  end

end


if __FILE__ == $0
  # Example usage
  config = TogoID::Config.new(ARGV.shift)

  # Output RDF/Turtle
  config.convert
end

