#!/bin/sh

# 20210204 moriya

# SPARQL query
QUERY="PREFIX wp: <http://vocabularies.wikipathways.org/wp#>
SELECT DISTINCT ?pathway ?doid
WHERE {
  ?pathway a wp:Pathway ;
           wp:diseaseOntologyTag ?doid .
}"

# curl -> format -> delete header
curl -H "Accept: text/csv" --data-urlencode "query=$QUERY" http://sparql.wikipathways.org/sparql | sed -e 's/\"//g; s/http:\/\/identifiers\.org\/wikipathways\///g; s/http:\/\/purl\.obolibrary\.org\/obo\///g; s/,/\t/g' | sed  -n '2,$p'

