#!/usr/bin/sh
set -euo pipefail

# PubChem IDとPubMed IDのペアを取得する。

ENDPOINT=https://integbio.jp/rdf/ebi/sparql
LIMIT=1000000 # SPARQLエンドポイントにおける取得可能データ件数の最大値
CURL=/usr/bin/curl

# ChEMBL IDとPubMed IDのペアを取得するクエリのテンプレート。
# 100万件以上あるので、本スクリプト中で、OFFSET/LIMIT を sed で追加して用いる。
CHEMBL_PUBMED_QUERY_FILE=query.rq
# 上記クエリで得られる結果の全件数を取得するクエリのテンプレート。
COUNT_CHEMBL_PUBMED_QUERY_FILE=query_count.rq

if [ ! -e $CHEMBL_PUBMED_QUERY_FILE ]; then echo "必要なファイルが不足しています。:$CHEMBL_PUBMED_QUERY_FILE"; exit; fi
if [ ! -e $COUNT_CHEMBL_PUBMED_QUERY_FILE ]; then echo "必要なファイルが不足しています。:$COUNT_CHEMBL_PUBMED_QUERY_FILE"; exit; fi

C2P_TOTAL=$($CURL -sSH "Accept: text/csv" --data-urlencode query@$COUNT_CHEMBL_PUBMED_QUERY_FILE $ENDPOINT | tail -1)
#echo 取得対象C2P数: $C2P_TOTAL
COUNT=$(expr $C2P_TOTAL / $LIMIT)

for i in $(seq 0 ${COUNT}); do
  QUERY=$(sed -e "$ a OFFSET ${i}000000 LIMIT ${LIMIT}" $CHEMBL_PUBMED_QUERY_FILE)
  $CURL -sSH "Accept: text/tab-separated-values" --data-urlencode query="$QUERY" $ENDPOINT | tail -qn +2 | sed -e 's/"//g'
done
