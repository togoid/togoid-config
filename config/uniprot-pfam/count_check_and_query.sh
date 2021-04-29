#!/usr/bin/sh
set -euo pipefail
# 100万件ヒットしているファイル(=Pfam ID)を検索し、
# 見つかったらそのPfam IDと繋がるUniProt ID全件数をカウントし、
# それに基づきOFFSET/LIMITを用いた繰り返しクエリを実行する。
TARGET=$1
ENDPOINT=$2
LIMIT=$3
CURL=/usr/bin/curl
#ENDPOINT=https://integbio.jp/rdf/mirror/uniprot/sparql
PAIR=($(wc -l $TARGET))
if [ ${PAIR[0]} -gt $LIMIT ] ; then
  MTM=$(echo ${PAIR[1]} | grep -o 'PF[0-9]*')
  QUERY=$(sed -e "s/__PFAM_ID__/${MTM}/" get_uniprot_pfam_list_pfam_count.rq)
#  echo $QUERY
  TOTAL=$($CURL -s -H "Accept: text/tab-separated-values" --data-urlencode query="$QUERY" $ENDPOINT | tail -n +2)
  COUNT=$(expr $TOTAL / $LIMIT)
#  echo $COUNT
  for i in $(seq ${COUNT})
  do
    IQUERY=$(sed -e "s/__PFAM_ID__/${MTM}/" -e "$ a OFFSET ${i}000000 LIMIT ${LIMIT}" get_uniprot_pfam_list_pfam.rq)
#    echo $IQUERY
    $CURL -sSH "Accept: text/tab-separated-values" --data-urlencode query="$IQUERY" $ENDPOINT | tail -n +2 >> $TARGET
  done
fi
