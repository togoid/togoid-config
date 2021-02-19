#!/bin/sh
# SPARQL query
QUERY="PREFIX m2r: <http://med2rdf.org/ontology/med2rdf#>
PREFIX dct: <http://purl.org/dc/terms/>
SELECT ?civicgene_id ?enst_id
WHERE {
  ?civicgene a m2r:Gene;
      dct:identifier ?civicgene_id ;
      m2r:variation ?var .
  ?var m2r:transcript ?enst
  BIND (replace(str(?enst), 'http://rdf.ebi.ac.uk/resource/ensembl.transcript/', '') AS ?enst_id)
}"
# curl -> format -> delete header
curl -sSf -H "Accept: text/csv" --data-urlencode "query=$QUERY" http://sparql.med2rdf.org/sparql | sed -e 's/\"//g;  s/,/\t/g' | sed -e '1d'
