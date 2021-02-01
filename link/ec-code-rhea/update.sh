#!/bin/sh

ENDPOINT='https://integbio.jp/rdf/misc/sparql'
OUTPUT='pair.tsv'
if ["${LIMIT}" = ""]; then
  LIMIT=10
fi

printf 'ENDPOINT: %s \n' ${ENDPOINT}
printf 'OUTPUT: %s \n' ${OUTPUT}

cat - << EOS > sparql.rq
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX taxon: <http://identifiers.org/taxonomy/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX identifiers: <http://identifiers.org/>
PREFIX rhea: <http://rdf.rhea-db.org/>

SELECT DISTINCT ?ec_id ?rhea_id
FROM <http://integbio.jp/rdf/mirror/rhea>
WHERE {
  {
    ?rhea rdfs:subClassOf rhea:Reaction
  } UNION {
    ?rhea rdfs:subClassOf rhea:DirectionalReaction
  } UNION {
    ?rhea rdfs:subClassOf rhea:BidirectionalReaction
  }
  ?rhea rhea:accession ?rhea_acc ;
        rhea:ec ?ec .
  BIND(STRAFTER(str(?rhea_acc), "RHEA:") AS ?rhea_id)
  BIND(STRAFTER(str(?ec), "enzyme/") AS ?ec_id)
}
LIMIT ${LIMIT}
EOS

echo "curl -H 'Accept: text/tab-separated-values' --data-urlencode \'query@sparql.rq\' https://integbio.jp/rdf/misc/sparql | tail +2 | tr -d '\"' > ./pair.tsv"
curl -H 'Accept: text/tab-separated-values' --data-urlencode 'query@sparql.rq' ${ENDPOINT} | tail +2 | tr -d '"' > ./${OUTPUT}
