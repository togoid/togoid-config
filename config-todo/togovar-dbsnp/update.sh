#!/bin/sh
# SPARQL query
QUERY="
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX tgvo: <http://biohackathon.org/resource/faldo#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX tgvo: <http://togovar.biosciencedbc.jp/vocabulary/>
PREFIX idt: <http://identifiers.org/>

SELECT distinct ?tgv_id ?rs
WHERE
{
  GRAPH <http://togovar.biosciencedbc.jp/variation>{
    ?variation dct:identifier ?tgv_id.
    ?variation rdfs:seeAlso ?dbsnp .
  }
  BIND(REPLACE(STR(?dbsnp), 'http://identifiers.org/dbsnp/', '') AS ?rs)
}"
# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" https://togovar-dev.biosciencedbc.jp/sparql | sed -e 's/\"//g;  s/,/\t/g' | sed -e '1d' 
