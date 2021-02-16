#!/bin/sh
# 20210209 takatsuki
# SPARQL query
QUERY="PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX oboInOwl: <http://www.geneontology.org/formats/oboInOwl#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema>
SELECT DISTINCT ((?s)AS ?ORDO_ID) (STR(?id) AS ?ID)
FROM <http://integbio.jp/rdf/mirror/bioportal/doid>
WHERE {
  ?s oboInOwl:hasDbXref ?id.
   FILTER(contains(?id,'OMIM'))
        }"
# curl -> format -> delete header
curl -H "Accept: text/csv" --data-urlencode "query=$QUERY" https://integbio.jp/rdf/mirror/bioportal/sparql | sed -e 's/\"//g; s/,/\t/g; s/http:\/\/purl.obolibrary.org\/obo\/DOID_/DOID:/g' | sed -e '1d'> pair.tsv