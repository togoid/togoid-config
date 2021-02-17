#!/usr/bin/env ruby
require 'optparse'
require 'open3'

params = ARGV.getopts("l:e:h", "limit:", "endpoint:")

help = <<"EOS"
  Usage: update.rb [options]
    -l <number of limit | all>
    -e <endpoint uri>
    -h
        --limit=<number of limit | all>
        --endpoint=<endpoint uri>
EOS

if params["h"] || params["help"]
  STDERR.print "#{help}"
  exit
end

if params["endpoint"]
  ENDPOINT = params["endpoint"]
else
  ENDPOINT = 'https://integbio.jp/rdf/bioportal/sparql'
end

if params["limit"] == "all"
  LIMIT = ""
elsif params["limit"]
  LIMIT = "LIMIT #{params["limit"]}"
else
  LIMIT = "LIMIT 2"
end

STDERR.print "ENDPOINT: #{ENDPOINT}\n"
STDERR.print "#{LIMIT}\n"

sparql = <<"EOS"
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix : <http://www.w3.org/2002/07/owl#>
prefix mondo: <http://purl.obolibrary.org/obo/mondo#>
prefix skos: <http://www.w3.org/2004/02/skos/core#>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix obo: <http://purl.obolibrary.org/obo/>

SELECT ?mondo_id ?meddra_id
FROM <http://integbio.jp/rdf/mirror/bioportal/mondo>
WHERE {
  ?mondo a :Class ;
    skos:notation ?mondo_compact_id ;
    mondo:exactMatch ?xref
  FILTER(REGEX(?xref, "meddra"))
  BIND(STRAFTER(str(?xref), "meddra/") AS ?meddra_id)
  BIND(CONCAT("MONDO_", STRAFTER(?mondo_compact_id, "MONDO:")) AS ?mondo_id)
}
#{LIMIT}
EOS

#STDERR.print "curl -s -H 'Accept: text/tab-separated-values' --data-urlencode \'query=#{sparql_1.gsub("\n", " ")}\' #{ENDPOINT}| tail +2 | tr -d '\"'\n"

result, status = Open3.capture2("curl -s -H 'Accept: text/tab-separated-values' --data-urlencode 'query=#{sparql.gsub("\n", " ")}' #{ENDPOINT}| tail +2 | tr -d '\"'")

puts result

