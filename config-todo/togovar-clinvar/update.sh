#!/bin/sh
# SPARQL query
QUERY="
PREFIX tgvo: <http://togovar.biosciencedbc.jp/vocabulary/>
PREFIX dct: <http://purl.org/dc/terms/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX cvo:  <http://purl.jp/bio/10/clinvar/>

SELECT ?tgv_id ?vcv
WHERE {
  GRAPH <http://togovar.biosciencedbc.jp/variation>{
     ?variation dct:identifier ?tgv_id.
  }
  
  GRAPH <http://togovar.biosciencedbc.jp/variation/annotation/clinvar>{
     ?variation tgvo:condition ?condition .
     ?condition rdfs:seeAlso ?clinvar .
  }
  
  BIND(REPLACE(STR(?clinvar), 'http://ncbi.nlm.nih.gov/clinvar/variation/', '') AS ?vcv) 
}"
# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" https://togovar-dev.biosciencedbc.jp/sparql | sed -e 's/\"//g;  s/,/\t/g' | sed -e '1d'
