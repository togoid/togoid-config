#!/bin/sh
# SPARQL query
QUERY="PREFIX dct: <http://purl.org/dc/terms/>
PREFIX orth: <http://purl.org/net/orth#>
PREFIX mbgd: <http://purl.jp/bio/11/mbgd#>
PREFIX taxid: <http://identifiers.org/taxonomy/>
SELECT (replace(str(?gene), "http://mbgd.genome.ad.jp/rdf/resource/gene/", "") as ?mbgd_gene_id) 
(replace(str(?uniprot), "http://purl.uniprot.org/uniprot/", "") as ?uniprot_id) 
 WHERE {
    ?gene a orth:Gene ;
          mbgd:taxon taxid:9606 ;
          mbgd:uniprot ?uniprot .
}
ORDER BY ?mbgd_gene_id"
# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" http://sparql.nibb.ac.jp/sparql | sed -e 's/\"//g;  s/,/\t/g' | sed -e '1d' > link.tsv