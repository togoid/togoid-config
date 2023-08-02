#!/usr/bin/bash
set -euo pipefail

# GlyTouCan IDとDOIDのペアを取得する。
# 構成としては、Genome AllianceとDisGeNetからのデータを取得するSPRQLクエリをそれぞれquery1.rq、query2.rqでエンドポイントに発行して、それを元にペアを生成する。
# 両者をUNIONで結ぶと180秒の時間制限によるタイムアウトが生じる。

ENDPOINT=https://ts.glycosmos.org/sparql
WORKDIR=glytoucan_doid
#LIMIT=1000000 # SPARQLエンドポイントにおける取得可能データ件数の最大値
CURL=/usr/bin/curl

for i in $(seq 1 3); do
  if [ ! -e query${i}.rq ]; then echo "必要なファイルが不足しています。:query${i}.rq"; exit; fi
done

if [ ! -e $WORKDIR ]; then
  mkdir $WORKDIR
else
  rm -f ${WORKDIR}/*
fi

for i in $(seq 1 3); do
  $CURL -o ${WORKDIR}/query${i}.txt -sSH "Accept: text/tab-separated-values" --data-urlencode query@query${i}.rq $ENDPOINT
done

# エラー終了しているファイルを検索し、改めて検索、をエラーがなくなるまで行う。
# ファイル冒頭に "pubchem_id" が書かれていない場合に、エラーと判断する。
ERROR_FILES=$(find ${WORKDIR} -type f -exec sh -c '(head -1 {} | grep -m 1 -q "^.do") || basename {} .txt' \;)
while true; do
  if [ -n "$ERROR_FILES" ]; then
     for i in $ERROR_FILES; do
       $CURL -o ${WORKDIR}/${i}.txt -sSH "Accept: text/tab-separated-values" --data-urlencode query@${i}.rq $ENDPOINT
     done
     ERROR_FILES=$(for f in $ERROR_FILES; do echo ${WORKDIR}/${f}.txt; done | xargs -IFILE sh -c '(head -1 FILE | grep -m 1 -q "^\?do") || basename FILE .txt')
     sleep 5
  else
     break
  fi
done

./gen_pairs.pl ${WORKDIR}/query*.txt | sort -u
