#!/usr/bin/sh
set -euo pipefail

curl -o wurcs_glytoucan_subsumption.csv -sH 'Accept: text/csv' --data-urlencode query@query.rq https://ts.glycosmos.org/sparql
./mk_pair.pl
