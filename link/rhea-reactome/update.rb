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
  ENDPOINT = 'https://integbio.jp/rdf/misc/sparql'
end

if params["limit"] == "all"
  LIMIT = ""
elsif params["limit"]
  LIMIT = "LIMIT #{params["limit"]}"
else
  LIMIT = "LIMIT 2"
end

STDERR.print "ENDPOINT #{ENDPOINT}\n"
STDERR.print "#{LIMIT}\n"

sparql = <<"EOS"
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX taxon: <http://identifiers.org/taxonomy/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX identifiers: <http://identifiers.org/>
PREFIX rhea: <http://rdf.rhea-db.org/>

SELECT ?rhea_acc ?reactome_id
FROM <http://integbio.jp/rdf/mirror/rhea>
WHERE {
  {
    ?rhea rdfs:subClassOf rhea:Reaction
  } UNION {
    ?rhea rdfs:subClassOf rhea:DirectionalReaction
  } UNION {
    ?rhea rdfs:subClassOf rhea:BidirectionalReaction
  }
  ?rhea rhea:accession ?rhea_acc ;
        rdfs:seeAlso ?reactome .
  FILTER(REGEX(?reactome, "reactome"))
  BIND(STRAFTER(str(?reactome), "reactome/") AS ?reactome_id)
}
#{LIMIT}
EOS

#STDERR.print "curl -H 'Accept: text/tab-separated-values' --data-urlencode \'query=#{sparql_1.gsub("\n", " ")}\' #{ENDPOINT}| tail +2 | tr -d '\"'\n"

result, status = Open3.capture2("curl -H 'Accept: text/tab-separated-values' --data-urlencode 'query=#{sparql.gsub("\n", " ")}' #{ENDPOINT}| tail +2 | tr -d '\"'")

puts result

