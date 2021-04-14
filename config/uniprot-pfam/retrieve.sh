#!/bin/sh
set -euo pipefail

# 2021/04/13時点で186,681,389件(本家で確認)あるので、適宜seqの引数を増やす必要あり。

seq -f '%.0f' 0 1000000 190000000 | xargs -i sh -c "curl -sSH 'Accept: text/tab-separated-values' --data-urlencode query='PREFIX up: <http://purl.uniprot.org/core/> PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> PREFIX db: <http://purl.uniprot.org/database/> SELECT (substr(str(?uniprot),33) as ?uniprot_id) (substr(str(?target), 30) as ?target_id) { SELECT DISTINCT ?uniprot ?target ?g1 { GRAPH <http://sparql.uniprot.org/uniprot> { ?uniprot a up:Protein ; rdfs:seeAlso ?target . ?target up:database db:Pfam .}} offset "{}" limit 1000000}' https://integbio.jp/rdf/mirror/uniprot/sparql | tail -n +2" | sed -e 's/"//g'
