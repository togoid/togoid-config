#!/usr/bin/env ruby
require 'optparse'
require 'open3'

params = ARGV.getopts("l:e:h", "limit:", "endpoint:")

help = <<"EOS"
  Usage: update.rb [options]
    -l <number of limit | all>
    -e <endpoint uri>
    -h help
        --limit=<number of limit | all>
        --endpoint=<endpoint uri>
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
  ENDPOINT = 'https://integbio.jp/rdf/ebi/sparql'
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
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX taxon: <http://identifiers.org/taxonomy/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX identifiers: <http://identifiers.org/>

SELECT DISTINCT ?enst_id ?hgnc_id
WHERE {
  ?ensg obo:RO_0002162 taxon:9606 ;
        rdfs:seeAlso ?hgnc .
  ?hgnc a identifiers:hgnc .
  ?enst obo:SO_transcribed_from ?ensg ;
        dc:identifier ?enst_id .
  BIND(STRAFTER(str(?hgnc), "HGNC:") AS ?hgnc_id)
}
#{LIMIT}
EOS

#STDERR.print "curl -H 'Accept: text/tab-separated-values' --data-urlencode \'query=#{sparql.gsub("\n", " ")}\' #{ENDPOINT}| tail -n +2 | tr -d '\"'\n"

result, status = Open3.capture2("curl -H 'Accept: text/tab-separated-values' --data-urlencode 'query=#{sparql.gsub("\n", " ")}' #{ENDPOINT}| tail -n +2 | tr -d '\"'")

STDERR.print "#{status}\n" if $DEBUG
puts result
