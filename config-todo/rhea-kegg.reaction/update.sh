#!/bin/sh

# 20210215 moriya

# SPARQL query
QUERY="PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rhea: <http://rdf.rhea-db.org/>
SELECT DISTINCT ?rhea ?kegg
FROM <http://integbio.jp/rdf/mirror/rhea>
WHERE {
  ?rhea rdfs:subClassOf rhea:Reaction ;
        rhea:bidirectionalReaction ?bi_dir_rhea .
  ?bi_dir_rhea rdfs:subClassOf rhea:BidirectionalReaction ;
               rdfs:seeAlso ?kegg .
  FILTER (REGEX (?kegg, 'kegg.reaction'))
}"

# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" https://integbio.jp/rdf/mirror/misc/sparql | sed -e 's/\"//g; s/http:\/\/rdf\.rhea-db\.org\///g; s/http:\/\/identifiers\.org\/kegg\.reaction\///g; s/,/\t/g' | sed  -n '2,$p'

