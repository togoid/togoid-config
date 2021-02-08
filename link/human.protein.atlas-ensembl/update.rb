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
  ENDPOINT = 'https://integbio.jp/rdf/protein-atlas/sparql'
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
PREFIX : <http://www.proteinatlas.org/about/nanopubs/>
PREFIX hpa: <http://www.proteinatlas.org/>
PREFIX tissue: <http://purl.obolibrary.org/obo/caloha.obo#>
PREFIX np: <http://www.nanopub.org/nschema#>
PREFIX bfo: <http://purl.obolibrary.org/obo/>
PREFIX nif: <http://ontology.neuinfo.org/NIF/Backend/NIF-Quality.owl#>
PREFIX wp: <http://vocabularies.wikipathways.org/wp#>

SELECT DISTINCT ?hpa_id ?ensembl_id
WHERE {
  ?hpa a wp:GeneProduct
  BIND(STRAFTER(str(?hpa), "org/") AS ?hpa_id)
  BIND(?hpa_id AS ?ensembl_id)
}
#{LIMIT}
EOS

#STDERR.print "curl -H 'Accept: text/tab-separated-values' --data-urlencode \'query=#{sparql_1.gsub("\n", " ")}\' #{ENDPOINT}| tail +2 | tr -d '\"'\n"

result, status = Open3.capture2("curl -H 'Accept: text/tab-separated-values' --data-urlencode 'query=#{sparql.gsub("\n", " ")}' #{ENDPOINT}| tail +2 | tr -d '\"'")
puts result

