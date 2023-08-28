#!/bin/bash

REPLACE_EXPR='s/,/\t/g; s/\"//g; s/\r\n/\n/g'

# With '-w', "," is replaced only once per line.
# This is intended to be used for queries to obtain ID and label, where labels may have ",".
while getopts "w" optKey; do
    case "$optKey" in
        w)
            REPLACE_EXPR='s/,/\t/; s/\"//g; s/\r\n/\n/g'
            ;;
    esac
done
shift $((OPTIND - 1))

QUERY=$1
ENDPOINT=$2

# Note: sed in macOS doesn't interpret \t in | sed -E '1d; s/,/\t/g; s/\"//g'

curl -s -H "Accept: text/csv" --data-urlencode "query@$QUERY" "$ENDPOINT" | sed -E 1d | perl -pe "$REPLACE_EXPR"

