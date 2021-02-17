#!/bin/sh
# 20210217 takeru nakazato, hiromasaono
# SPARQL query
QUERY="PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX oboInOwl: <http://www.geneontology.org/formats/oboInOwl#>

SELECT DISTINCT ?go ?kegg
WHERE {
  FILTER(regex(?go, 'GO_'))
  ?go oboInOwl:hasDbXref ?kegg .
  FILTER(regex(?kegg, 'KEGG'))
}"
# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" https://integbio.jp/rdf/sparql | sed -e 's/\"//g;  s/http:\/\/purl.obolibrary.org\/obo\///g; s/KEGG://g; s/,/\t/g' | sed -e '1d' > pair.tsv