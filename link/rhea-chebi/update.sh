#!/bin/sh

# 20210215 moriya

# SPARQL query
QUERY="PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rhea: <http://rdf.rhea-db.org/>
PREFIX chebi: <http://purl.obolibrary.org/obo/CHEBI_>
SELECT DISTINCT (REPLACE (STR (?rhea_uri), rhea:, '') AS ?rhea) (REPLACE (STR (?chebi_uri), chebi:, '') AS ?chebi)
FROM <http://integbio.jp/rdf/mirror/rhea>
WHERE {
  VALUES ?class { rhea:Reaction rhea:DirectionalReaction }
  VALUES ?equation_side { rhea:side rhea:substrates rhea:products}
  ?rhea_uri rdfs:subClassOf ?class ;
        ?equation_side ?side .
  ?side rhea:contains ?participant_compound .
  ?participant_compound rhea:compound ?compound .
  ?compound rhea:chebi ?chebi_uri .
}"

# curl -> format -> delete header
curl -H "Accept: text/csv" --data-urlencode "query=$QUERY" https://integbio.jp/rdf/mirror/misc/sparql | sed -e 's/\"//g; s/,/\t/g' | sed  -n '2,$p'

