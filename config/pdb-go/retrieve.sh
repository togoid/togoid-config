#!/usr/bin/sh
set -euo pipefail

ENDPOINT=https://integbio.jp/rdf/pdb/sparql
CURL=/usr/bin/curl

# ペアを取得するクエリのテンプレート。
# 100万件以上あるので、本スクリプト中で、PDB ID の先頭文字(1~9)ごとに取得するよう FILTER 部分を sed で編集して用いる。
QUERY_FILE=query.rq

if [ ! -e $QUERY_FILE ]; then echo "必要なファイルが不足しています。:$QUERY_FILE"; exit; fi

for i in $(seq 1 9); do
  #TIME=`date "+%Y-%m-%d %H:%M:%S"`
  #echo "[$TIME] Fetching " $i 1>&2
  QUERY=$(sed -e "s/__NUM__/$i/g" $QUERY_FILE)
  $CURL -sSH "Accept: text/tab-separated-values" --data-urlencode query="$QUERY" $ENDPOINT | tail -qn +2 | sed -e 's/"//g'
  #echo "$QUERY"
done
