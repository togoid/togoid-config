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

sparql_1 = <<"EOS"
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX taxon: <http://identifiers.org/taxonomy/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX ensembl: <http://rdf.ebi.ac.uk/terms/ensembl/>

SELECT DISTINCT ?tax_id
WHERE {
  ?ensg obo:RO_0002162 ?taxon .
  ?taxon dc:identifier ?tax_id
  FILTER(REGEX(?taxon, "taxonomy/"))
}
#{LIMIT}
EOS

#STDERR.print "curl -H 'Accept: text/tab-separated-values' --data-urlencode \'query=#{sparql_1.gsub("\n", " ")}\' #{ENDPOINT}| tail -n +2 | tr -d '\"'\n"

tax_ids = Open3.capture2("curl -H 'Accept: text/tab-separated-values' --data-urlencode 'query=#{sparql_1.gsub("\n", " ")}' #{ENDPOINT}| tail -n +2 | tr -d '\"'")


tax_id_ary = tax_ids[0].split("\n")
tax_id_ary.each do |tax_id|

  sparql_2 = <<"EOS"
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dc: <http://purl.org/dc/elements/1.1/> 
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX taxon: <http://identifiers.org/taxonomy/>

SELECT DISTINCT ?ensg_id ?enst_id
WHERE {
  ?ensg obo:RO_0002162 taxon:#{tax_id} .
  ?ensg dc:identifier ?ensg_id .
  ?enst obo:SO_transcribed_from ?ensg ;
        dc:identifier ?enst_id .
}
#{LIMIT}
EOS

  STDERR.print "#{tax_id}\n" if $DEBUG

  result, status = Open3.capture2("curl -H 'Accept: text/tab-separated-values' --data-urlencode 'query=#{sparql_2.gsub("\n", " ")}' #{ENDPOINT}| tail -n +2 | tr -d '\"'")

  STDERR.print "#{status}\n" if $DEBUG

  puts result
end
