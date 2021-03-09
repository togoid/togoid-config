#!/bin/sh
# 20210209 takatsuki
# SPARQL query
QUERY="PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX oboInOwl: <http://www.geneontology.org/formats/oboInOwl#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema>
SELECT DISTINCT ?MONDO_ID ?HP_ID
FROM <http://integbio.jp/rdf/mirror/bioportal/mondo>
WHERE {
  ?s oboInOwl:hasDbXref ?id.
   FILTER(contains(?id,'HP'))
   BIND (replace(str(?id), "HP:", "") AS ?HP_ID)
   BIND (replace(str(?s), "http://purl.obolibrary.org/obo/MONDO_", "") AS ?MONDO_ID) 
        }"
# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" https://integbio.jp/rdf/mirror/bioportal/sparql | sed -e 's/\"//g; s/,/\t/g; s/http:\/\/purl.obolibrary.org\/obo\/MONDO_/MONDO:/g' | sed -e '1d'
