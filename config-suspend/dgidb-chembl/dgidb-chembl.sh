#!/bin/sh
# 20210216 shin
# SPARQL query
QUERY="PREFIX dgio: <http://purl.jp/bio/10/dgidb/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterm: <http://purl.org/dc/terms/>

SELECT ?DGIDdb_id ?dgidb_drug_id
WHERE {
  ?DGIdbInteraction a dgio:Interaction ;
                    dcterm:identifier ?DGIDdb_id ;
                    dgio:drug ?DGIdbDrug .
  ?DGIdbDrug a dgio:Drug ;
             rdfs:seeAlso ?dgidb_drug .
  BIND (replace(str(?dgidb_drug), 'http://rdf.ebi.ac.uk/resource/chembl/molecule/', '') AS ?dgidb_drug_id)
}"
# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" http://sparql.med2rdf.org/sparql | sed -e 's/\"//g; s/,/\t/g' | sed -e '1d'> pair.tsv
