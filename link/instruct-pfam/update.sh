#!/bin/sh
# SPARQL query
QUERY="PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX pint: <http://purl.jp/10/pint/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX ins: <http://purl.jp/10/instruct/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX uni: <http://identifiers.org/uniprot/>
PREFIX pfm: <http://identifiers.org/Pfam/>
PREFIX bp3: <http://www.biopax.org/release/biopax-level3.owl#>

SELECT  (replace(str(?instruct), "http://purl.jp/10/instruct/", "") as ?instruct_id)   (replace(str(?pfam), "http://identifiers.org/Pfam/", "") as ?pfam_id)
FROM <http://med2rdf.org/graph/instruct> 
where {
   ?instruct a bp3:MolecularInteraction ;
      bp3:participant / obo:BFO_0000051 ?pfam .
  FILTER(CONTAINS(STR(?pfam), "http://identifiers.org/Pfam/"))
  }
ORDER BY ?instruct_id"
# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" http://sparql.med2rdf.org/sparql | sed -e 's/\"//g;  s/,/\t/g' | sed -e '1d' > link.tsv