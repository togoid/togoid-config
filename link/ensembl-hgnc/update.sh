#!/bin/sh

#SPARQL='sparql.rq'
ENDPOINT='https://integbio.jp/rdf/ebi/sparql'
OUTPUT='pair.tsv'

printf 'SPARQL: %s \n' ${SPARQL}
printf 'ENDPOINT: %s \n' ${ENDPOINT}
printf 'OUTPUT: %s \n' ${OUTPUT}

cat - << EOS > sparql.rq
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX taxon: <http://identifiers.org/taxonomy/>

SELECT ?ensg_id ?hgnc_id
WHERE {
  ?ensg obo:RO_0002162 taxon:9606 ;
        dc:identifier ?ensg_id ;
        rdfs:seeAlso ?hgnc .
  ?hgnc dct:identifier ?hgnc_id .
}
EOS

echo "curl -H 'Accept: text/tab-separated-values' --data-urlencode \'query@sparql.rq\' https://integbio.jp/rdf/ebi/sparql | tail +2 | tr -d '\"' > ./pair.tsv"
curl -H 'Accept: text/tab-separated-values' --data-urlencode 'query@sparql.rq' ${ENDPOINT} | tail +2 | tr -d '"' > ./${OUTPUT}
