#!/bin/sh
# 20210210 hiromasaono
# SPARQL query
QUERY="PREFIX refexo: <http://purl.jp/bio/01/refexo#>
SELECT DISTINCT ?gene_id ?affy_id
WHERE {
  ?gene refexo:affyProbeset ?affy .
  BIND (replace(str(?gene), 'http://identifiers.org/ncbigene/', '') AS ?gene_id)
  BIND (replace(str(?affy), 'http://identifiers.org/affy.probeset/', '') AS ?affy_id)
}
ORDER BY ?gene"
# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" https://orth.dbcls.jp/sparql-dev | sed -e 's/\"//g;  s/,/\t/g' | sed -e '1d' > pair.tsv
