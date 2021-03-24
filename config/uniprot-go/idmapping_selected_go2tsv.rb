#!/usr/bin/env ruby

ARGF.each do |line|
  up_id, go_ids = line.strip.split(/\t/)
  go_ids.split(/;\s+/).each do |go_id|
    puts "#{up_id}\t#{go_id.sub('GO:', '')}"
  end
end
