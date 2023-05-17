#!/usr/bin/sh
set -euo pipefail

ENDPOINT=https://integbio.jp/rdf/pdb/sparql
LIMIT=1000000 # SPARQLエンドポイントにおける取得可能データ件数の最大値
CURL=/usr/bin/curl

# ペアを取得するクエリのテンプレート。
# 100万件以上あるので、本スクリプト中で、OFFSET/LIMIT を sed で追加して用いる。
QUERY_FILE=query.rq
# 上記クエリで得られる結果の全件数を取得するクエリのテンプレート。
COUNT_QUERY_FILE=query_count.rq

if [ ! -e $QUERY_FILE ]; then echo "必要なファイルが不足しています。:$QUERY_FILE"; exit; fi
if [ ! -e $COUNT_QUERY_FILE ]; then echo "必要なファイルが不足しています。:$COUNT_QUERY_FILE"; exit; fi

PAIR_TOTAL=$($CURL -sSH "Accept: text/csv" --data-urlencode query@$COUNT_QUERY_FILE $ENDPOINT | tail -1)
echo "Number of pairs to fetch: $PAIR_TOTAL" 1>&2
COUNT=$(expr $PAIR_TOTAL / $LIMIT)

for i in $(seq 0 ${COUNT}); do
  QUERY=$(sed -e "$ a OFFSET ${i}000000 LIMIT ${LIMIT}" $QUERY_FILE)
  $CURL -sSH "Accept: text/tab-separated-values" --data-urlencode query="$QUERY" $ENDPOINT | tail -qn +2 | sed -e 's/"//g'
done
