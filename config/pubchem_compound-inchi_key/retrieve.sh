#!/usr/bin/bash
set -euo pipefail

# PubChem IDとInChiIKey IDのペアを取得する。

ENDPOINT=https://integbio.jp/rdf/pubchem/sparql
WORKDIR=pubchem2inchikey # 一時的にIDペアファイルを保存するディレクトリ
LIMIT=1000000 # SPARQLエンドポイントにおける取得可能データ件数の最大値
CURL=/usr/bin/curl
XARGS=/usr/bin/xargs

# PubChem Compound IDとInChIKeyのペアを取得するクエリのテンプレート。
# 100万件以上あるので、本スクリプト中で、OFFSET/LIMIT を sed で追加して用いる。
PUBCHEM_INCHIKEY_QUERY_FILE=query_01.rq
# 上記クエリで得られる結果の全件数を取得するクエリのテンプレート。
COUNT_PUBCHEM_INCHIKEY_QUERY_FILE=query_01_count.rq

if [ ! -e $PUBCHEM_INCHIKEY_QUERY_FILE ]; then echo "必要なファイルが不足しています。:$PUBCHEM_INCHIKEY_QUERY_FILE"; exit; fi
if [ ! -e $COUNT_PUBCHEM_INCHIKEY_QUERY_FILE ]; then echo "必要なファイルが不足しています。:$COUNT_PUBCHEM_INCHIKEY_QUERY_FILE"; exit; fi

if [ ! -e $WORKDIR ]; then
  mkdir $WORKDIR
else
  rm -f ${WORKDIR}/*
fi

C2P_TOTAL=$($CURL -sSH "Accept: text/csv" --data-urlencode query@$COUNT_PUBCHEM_INCHIKEY_QUERY_FILE $ENDPOINT | tail -1)
#C2P_TOTAL=110040634
#echo 取得対象C2P数: $C2P_TOTAL
COUNT=$(expr $C2P_TOTAL / $LIMIT)

declare -a query_list=()
for i in $(seq 0 ${COUNT}); do
  QUERY=$(sed -e "1 i #${i}" -e "$ a OFFSET ${i}000000 LIMIT ${LIMIT}" $PUBCHEM_INCHIKEY_QUERY_FILE)
  query_list+=( "${QUERY}" )
done

IFS=$'\t'
echo -n "${query_list[*]}" | $XARGS -P 5 -i -d '\t' ./issue_query.sh ${WORKDIR} "{}" tsv $ENDPOINT 

# エラー終了しているファイルを検索し、改めて検索、をエラーがなくなるまで行う。
# ファイル冒頭に "cid_str" が書かれていない場合に、エラーと判断する。
IFS=$'\n' ERROR_FILES=$(find ${WORKDIR} -type f -exec sh -c '(head -1 {} | grep -m 1 -q "^\"cid_str\"") || basename {} .tsv' \;)
while true; do
  if [ -n "$ERROR_FILES" ]; then
     for i in $ERROR_FILES; do
       QUERY=$(sed -e "$ a OFFSET ${i}000000 LIMIT ${LIMIT}" $PUBCHEM_INCHIKEY_QUERY_FILE)
       $CURL -o ${WORKDIR}/${i}.tsv -sSH "Accept: text/tab-separated-values" --data-urlencode query="$QUERY" $ENDPOINT
     done
     ERROR_FILES=$(for f in $ERROR_FILES; do echo ${WORKDIR}/${f}.tsv; done | $XARGS -i sh -c '(head -1 {} | grep -m 1 -q "^\"cid_str\"") || basename {} .tsv')
     sleep 5
  else
     break
  fi
done

tail -qn +2 ${WORKDIR}/*.tsv | sed -e 's/"//g'
