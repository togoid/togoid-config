#!/bin/sh
set -euo pipefail

# 2021/04/13時点で10570899件あるので、適宜seqの引数を増やす必要あり。

seq -f '%.0f' 0 1000000 11000000 | xargs -i sh -c "curl -sSH 'Accept: text/tab-separated-values' --data-urlencode query='PREFIX obo: <http://purl.obolibrary.org/obo/> PREFIX bp: <http://www.biopax.org/release/biopax-level3.owl#> PREFIX skos: <http://www.w3.org/2004/02/skos/core#> select (substr(str(?cid),49) AS ?_cid) (substr(str(?up),33) AS ?_up) { select distinct ?cid ?up { ?cid ^obo:RO_0000057 [ a bp:Pathway ; obo:RO_0000057 [ a bp:Protein ;skos:closeMatch ?up ]]. filter contains(str(?up),\"unip\")} offset "{}" limit 1000000}' https://integbio.jp/rdf/pubchem/sparql | tail -n +2" | sed -e 's/"//g'
