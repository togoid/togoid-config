#!/bin/sh
# SPARQL query

if [ $# -ne 1 ]; then
  echo "usage: ./update.sh TARGET" 1>&2
  exit 1
fi
TARGET=$1

ENDPOINT="http://sparql.med2rdf.org/sparql"
QUERY="PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX m2r: <http://med2rdf.org/ontology/med2rdf#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX idt: <http://identifiers.org/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT DISTINCT ?hgnc_id ?target_id
FROM <http://med2rdf.org/graph/hgnc>
WHERE {
  ?HGNC a  obo:SO_0000704, m2r:Gene ;
    dct:identifier ?hgnc_id ;
    rdfs:seeAlso ?target .
    ?target a idt:${TARGET} ;
      dct:identifier ?target_id .
}"

curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" $ENDPOINT | sed -E '1d; s/,/\t/g; s/\"//g'

