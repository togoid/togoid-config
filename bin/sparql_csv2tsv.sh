#!/bin/sh

QUERY=$1
ENDPOINT=$2

# Note: sed in macOS doesn't interpret \t in | sed -E '1d; s/,/\t/g; s/\"//g'

curl -s -H "Accept: text/csv" --data-urlencode "query@$QUERY" "$ENDPOINT" | sed -E 1d | perl -pe 's/,/\t/g; s/\"//g'

