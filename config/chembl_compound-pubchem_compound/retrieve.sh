#!/usr/bin/sh
set -euo pipefail

# PubChem IDとChEMBL IDのペアを取得する。

ENDPOINT=https://integbio.jp/rdf/ebi/sparql
WORKDIR=chembl2pubchem # 一時的にIDペアファイルを保存するディレクトリ
LIMIT=1000000 # SPARQLエンドポイントにおける取得可能データ件数の最大値
CURL=/usr/bin/curl

# ChEMBL IDとPubChem IDのペアを取得するクエリのテンプレート。
# 100万件以上あるので、本スクリプト中で、OFFSET/LIMIT を sed で追加して用いる。
CHEMBL_PUBCHEM_QUERY_FILE=query_01.rq
# 上記クエリで得られる結果の全件数を取得するクエリのテンプレート。
COUNT_CHEMBL_PUBCHEM_QUERY_FILE=query_01_count.rq

if [ ! -e $CHEMBL_PUBCHEM_QUERY_FILE ]; then echo "必要なファイルが不足しています。:$CHEMBL_PUBCHEM_QUERY_FILE"; exit; fi
if [ ! -e $COUNT_CHEMBL_PUBCHEM_QUERY_FILE ]; then echo "必要なファイルが不足しています。:$COUNT_CHEMBL_PUBCHEM_QUERY_FILE"; exit; fi

if [ ! -e $WORKDIR ]; then
  mkdir $WORKDIR
else
  rm -f ${WORKDIR}/*
fi

C2P_TOTAL=$($CURL -sSH "Accept: text/csv" --data-urlencode query@$COUNT_CHEMBL_PUBCHEM_QUERY_FILE $ENDPOINT | tail -1)
#echo 取得対象C2P数: $C2P_TOTAL
COUNT=$(expr $C2P_TOTAL / $LIMIT)

for i in $(seq 0 ${COUNT}); do
  QUERY=$(sed -e "$ a OFFSET ${i}000000 LIMIT ${LIMIT}" $CHEMBL_PUBCHEM_QUERY_FILE)
  $CURL -o ${WORKDIR}/${i}.txt -sSH "Accept: text/tab-separated-values" --data-urlencode query="$QUERY" $ENDPOINT
done

# エラー終了しているファイルを検索し、改めて検索、をエラーがなくなるまで行う。
# ファイル冒頭に "chembl_id" が書かれていない場合に、エラーと判断する。
ERROR_FILES=$(find ${WORKDIR} -type f -exec sh -c '(head -1 {} | grep -m 1 -q "^\"chembl_id\"") || basename {} .txt' \;)
while true; do
  if [ -n "$ERROR_FILES" ]; then
     for i in $ERROR_FILES; do
       QUERY=$(sed -e "$ a OFFSET ${i}000000 LIMIT ${LIMIT}" $CHEMBL_PUBCHEM_QUERY_FILE)
       $CURL -o ${WORKDIR}/${i}.txt -sSH "Accept: text/tab-separated-values" --data-urlencode query="$QUERY" $ENDPOINT
     done
     ERROR_FILES=$(for f in $ERROR_FILES; do echo ${WORKDIR}/${f}.txt; done | xargs -i sh -c '(head -1 {} | grep -m 1 -q "^\"chembl_id\"") || basename {} .txt')
     sleep 5
  else
     break
  fi
done

tail -qn +2 ${WORKDIR}/*.txt | sed -e 's/"//g'
