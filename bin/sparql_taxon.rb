#!/usr/bin/env ruby

query_file    = ARGV.shift || "query.rq"
endpoint      = ARGV.shift || "https://rdfportal.org/ebi/sparql"
taxonomy_list = ARGV.shift || "../../input/ensembl/taxonomy.txt"

query_template = File.read(query_file)
limit = 1000000

File.read(taxonomy_list).split("\n").each do |taxon|
  i = 0
  loop_count = 0
  while i % limit == 0
    if loop_count * limit != i
      $stderr.puts "Warning: Failed to retrieve taxon:#{taxon} in loop_count:#{loop_count}"
      break
    end
    query = query_template.sub('{{taxon}}', taxon) + " OFFSET #{i} LIMIT #{limit}"
    cmd = "curl -s -H 'Accept: text/csv' --data-urlencode 'query=#{query}' #{endpoint} | sed -E 1d"
    IO.popen(cmd) do |io|
      while buffer = io.gets
        puts buffer.gsub(',', "\t").gsub('"', '')
        i += 1
      end
    end
    loop_count += 1
  end
end
