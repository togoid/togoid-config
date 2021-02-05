#!/usr/bin/env ruby
#
# Usage: freq-summary.rb link/*/*.yaml
#

require 'yaml'

ARGV.each do |yaml|
  begin
    config = YAML.load(File.read(yaml))
    pair = File.basename(File.dirname(yaml))
    puts [pair, config["update"]["frequency"]].join("\t")
  rescue => error
    puts [yaml, error].join("\t")
    next
  end
end



