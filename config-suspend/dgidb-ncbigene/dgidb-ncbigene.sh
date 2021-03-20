#!/bin/sh
# 20210216 shin
# SPARQL query
QUERY="PREFIX dgio: <http://purl.jp/bio/10/dgidb/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dcterm: <http://purl.org/dc/terms/>

SELECT ?DGIDdb_id ?ncbi_gene_id 
WHERE { 
  ?DGIdbInteraction a dgio:Interaction ;
                    dcterm:identifier ?DGIDdb_id ;
                    dgio:gene ?DGIdbGene .
  ?DGIdbGene a dgio:Gene ;
             rdfs:seeAlso ?ncbi_gene .
  BIND (replace(str(?ncbi_gene), 'http://identifiers.org/ncbigene/', '') AS ?ncbi_gene_id)
}"
# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" http://sparql.med2rdf.org/sparql | sed -e 's/\"//g; s/,/\t/g' | sed -e '1d'
