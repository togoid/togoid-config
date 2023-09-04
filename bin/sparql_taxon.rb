#!/usr/bin/env ruby

query_file    = ARGV.shift || "query.rq"
endpoint      = ARGV.shift || "https://rdfportal.org/ebi/sparql"
taxonomy_list = ARGV.shift || "../../input/ensembl/taxonomy.txt"

query_template = File.read(query_file)

File.read(taxonomy_list).split("\n").each do |taxon|
  query = query_template.sub('{{taxon}}', taxon)
  cmd = "curl -s -H 'Accept: text/csv' --data-urlencode 'query=#{query}' #{endpoint} | sed -E 1d"
  IO.popen(cmd) do |io|
    while buffer = io.gets
      puts buffer.gsub(',', "\t").gsub('"', '')
    end
  end
end
