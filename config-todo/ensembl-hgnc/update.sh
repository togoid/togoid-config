#!/bin/sh

ENDPOINT='https://integbio.jp/rdf/ebi/sparql'

#if ["${LIMIT}" = ""]; then
#  LIMIT=10
#fi

cat - << EOS > sparql.rq
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX taxon: <http://identifiers.org/taxonomy/>
PREFIX identifiers: <http://identifiers.org/>

SELECT DISTINCT ?ensg_id ?hgnc_id
WHERE {
  ?ensg obo:RO_0002162 taxon:9606 ;
        dc:identifier ?ensg_id ;
        rdfs:seeAlso ?hgnc .
  ?hgnc a identifiers:hgnc .
  ?hgnc dc:identifier ?hgnc_compact_id .
  BIND(STRAFTER(?hgnc_compact_id, "HGNC:") AS ?hgnc_id)
}
EOS

echo "curl -s -H 'Accept: text/tab-separated-values' --data-urlencode \'query@sparql.rq\' https://integbio.jp/rdf/ebi/sparql | tail -n +2 | tr -d '\"' > ./pair.tsv"
curl -s -H 'Accept: text/tab-separated-values' --data-urlencode 'query@sparql.rq' ${ENDPOINT} | tail -n +2 | tr -d '"'
