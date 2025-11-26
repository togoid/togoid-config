#!/bin/bash

REPLACE_EXPR='s/\"//g; s/\r\n/\n/g'
QUERY=$1
ENDPOINT=$2

curl -s -H "Accept: text/tab-separated-values" --data-urlencode "query@$QUERY" "$ENDPOINT" | sed -E '1d; s/"//g; s/\r\n/\n/g'
