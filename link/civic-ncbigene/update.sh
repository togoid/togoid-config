#!/bin/sh
# SPARQL query
QUERY="PREFIX m2r: <http://med2rdf.org/ontology/med2rdf#>
PREFIX dct: <http://purl.org/dc/terms/>
SELECT DISTINCT ?civicgene_id ?ncbigene_id
WHERE {
  ?civicgene a m2r:Gene;
      dct:identifier ?civicgene_id ;
      rdfs:seeAlso ?ncbigene .
  ?ncbigene a <http://identifiers.org/ncbigene> .
  BIND (replace(str(?ncbigene), 'http://identifiers.org/ncbigene/', '') AS ?ncbigene_id)
}"
# curl -> format -> delete header
curl -sSf -H "Accept: text/csv" --data-urlencode "query=$QUERY" http://sparql.med2rdf.org/sparql | sed -e 's/\"//g;  s/,/\t/g' | sed -e '1d'
