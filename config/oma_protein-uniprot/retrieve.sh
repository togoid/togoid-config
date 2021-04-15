#!/bin/sh
set -euo pipefail

QUERY=`cat query.rq`
seq -f '%.0f' 0 1000000 $1 | xargs -i sh -c "curl -sSH 'Accept: text/tab-separated-values' --data-urlencode query='${QUERY} offset "{}" limit 1000000' https://sparql.omabrowser.org/sparql/" | sed -e 's/"//g'
