#!/bin/sh

ENDPOINT='http://sparql.med2rdf.org/sparql'
QUERY='PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX m2r: <http://med2rdf.org/ontology/med2rdf#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX idt: <http://identifiers.org/>

SELECT DISTINCT ?hgnc_id ?pubmed_id
FROM <http://med2rdf.org/graph/hgnc>
WHERE {
  ?HGNC a  obo:SO_0000704, m2r:Gene ;
    dct:identifier ?hgnc_id .
  ?HGNC dct:references ?PubMed .
  ?PubMed a idt:pubmed ;
    dct:identifier ?pubmed_id .
}'

curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" $ENDPOINT | sed -E '1d; s/,/\t/g; s/\"//g'
