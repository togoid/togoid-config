#!/bin/sh

# 20210215 moriya

# SPARQL query
QUERY="PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX wp: <http://vocabularies.wikipathways.org/wp#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
SELECT DISTINCT ?pathway ?uniprot
WHERE {
  ?pathway a wp:Pathway .
  ?uniprot dct:isPartOf* ?pathway ;
           a wp:Protein ;
           dc:source 'Uniprot-TrEMBL'^^xsd:string .
}"


# curl -> format -> delete header
curl -H "Accept: text/csv" --data-urlencode "query=$QUERY" http://sparql.wikipathways.org/sparql | sed -e 's/\"//g; s/http:\/\/identifiers\.org\/wikipathways\///g; s/http:\/\/identifiers\.org\/uniprot\///g; s/,/\t/g' | sed  -n '2,$p'

