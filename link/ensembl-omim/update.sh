#!/bin/sh

ENDPOINT='https://integbio.jp/rdf/ebi/sparql'
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
PREFIX identifiers: <http://identifiers.org/>

SELECT DISTINCT ?ensg_id ?omim_id
WHERE {
  ?ensg obo:RO_0002162 taxon:9606 ;
        dc:identifier ?ensg_id ;
        rdfs:seeAlso ?omim .
  ?omim a identifiers:omim .
  BIND(STRAFTER(STR(?omim), "omim/") AS ?omim_id)
}
LIMIT ${LIMIT}
EOS

echo "curl -H 'Accept: text/tab-separated-values' --data-urlencode \'query@sparql.rq\' https://integbio.jp/rdf/ebi/sparql | tail +2 | tr -d '\"' > ./pair.tsv"
curl -H 'Accept: text/tab-separated-values' --data-urlencode 'query@sparql.rq' ${ENDPOINT} | tail +2 | tr -d '"' > ./${OUTPUT}
