#!/usr/bin/env ruby
require 'optparse'
require 'open3'

params = ARGV.getopts("l:e:h", "limit:", "endpoint:", "help")

help = <<"EOS"
  Usage: update.rb [options]
    -l <number of limit | all>
    -e <endpoint uri>
    -h help
        --limit=<number of limit | all>
        --endpoint=<endpoint uri>

    example: > ./update.rb -l all -e https://togovar-dev.biosciencedbc.jp/sparql
EOS

if params["h"] || params["help"]
  STDERR.print "#{help}"
  exit
end

if params["endpoint"]
  ENDPOINT = params["endpoint"]
elsif params["e"]
  ENDPOINT = params["e"]
else
  ENDPOINT = 'https://togovar-dev.biosciencedbc.jp/sparql'
end

if params["limit"] == "all" || params["l"] == "all"
  LIMIT = ""
elsif params["limit"]
  LIMIT = "LIMIT #{params["limit"]}"
elsif params["l"]
  LIMIT = "LIMIT #{params["l"]}"
else
  LIMIT = "LIMIT 2"
end

STDERR.print "ENDPOINT #{ENDPOINT}\n" if $DEBUG
STDERR.print "#{LIMIT}\n"             if $DEBUG

sparql = <<"EOS"
PREFIX obo: <http://purl.obolibrary.org/obo/>

SELECT DISTINCT ?medgen_id ?ncbigene_id
WHERE {
  ?ncbigene obo:RO_0003302 ?medgen
  BIND(STRAFTER(str(?ncbigene), "ncbigene/") AS ?ncbigene_id)
  BIND(STRAFTER(str(?medgen), "medgen/") AS ?medgen_id)
}
ORDER BY ?medgen_id
#{LIMIT}
EOS

result, status = Open3.capture2("curl -H 'Accept: text/tab-separated-values' --data-urlencode 'query=#{sparql.gsub("\n", " ")}' #{ENDPOINT}| tail -n +2 | tr -d '\"'")

STDERR.print "#{status}\n" if $DEBUG

puts result

