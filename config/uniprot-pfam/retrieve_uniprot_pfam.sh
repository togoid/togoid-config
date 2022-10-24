#!/usr/bin/sh
set -euo pipefail
#set -euo pipefail errtrace

# UniProt IDとPfam IDのペアを取得する。

ENDPOINT=https://integbio.jp/rdf/mirror/uniprot/sparql
WORKDIR=pfam2uniprot # 一時的にPfamID毎のUniProtIDリストファイルを保存するディレクトリ
LIMIT=1000000 # SPARQLエンドポイントにおける取得可能データ件数の最大値
CURL="/usr/bin/curl -v"

# Pfam ID単位で対応するUniProt IDを取得するクエリのテンプレート。
# __PFAM_ID__ と書かれている部分を、実際のPfam ID（ex. PF00201）で置換する。
# $CHECK_SCRIPT 内でも利用される。
UNIPROT_PFAM_QUERY_FILE=get_uniprot_pfam_list_pfam.rq
# 上記クエリで得られる結果の全件数を取得するクエリのテンプレート。
# $CHECK_SCRIPT 内で利用される。
COUNT_UNIPROT_PFAM_QUERY_FILE=get_uniprot_pfam_list_pfam_count.rq

CHECK_SCRIPT=count_check_and_query.sh
FORMAT_SCRIPT=formatter.sh
GET_SCRIPT=issue_query.sh

if [ ! -e $UNIPROT_PFAM_QUERY_FILE ]; then echo "必要なファイルが不足しています。:$UNIPROT_PFAM_QUERY_FILE"; exit; fi
if [ ! -e $COUNT_UNIPROT_PFAM_QUERY_FILE ]; then echo "必要なファイルが不足しています。:$COUNT_UNIPROT_PFAM_QUERY_FILE"; exit; fi
if [ ! -e $CHECK_SCRIPT ]; then echo "必要なファイルが不足しています。:$CHECK_SCRIPT"; exit; fi
if [ ! -e $FORMAT_SCRIPT ]; then echo "必要なファイルが不足しています。:$FORMAT_SCRIPT"; exit; fi
if [ ! -e $GET_SCRIPT ]; then echo "必要なファイルが不足しています。:$GET_SCRIPT"; exit; fi

if [ ! -e $WORKDIR ]; then
  mkdir $WORKDIR
else
  rm -f ${WORKDIR}/*
fi

# Pfam IDのリストを取得。
$CURL -sSH 'Accept: text/tab-separated-values' --data-urlencode query@get_pfam_id.rq $ENDPOINT | grep -o 'PF[0-9]*' > pfam_id_list.txt

# Pfam ID毎にUniProt IDを取得。
echo "Pfam ID毎にUniProt IDを取得。" >&2
echo xargs -a pfam_id_list.txt -P20 -i sh $GET_SCRIPT ${WORKDIR}/{}.txt $ENDPOINT "{}"
xargs -a pfam_id_list.txt -P20 -i sh $GET_SCRIPT ${WORKDIR}/{}.txt $ENDPOINT "{}"

# エラー終了しているファイルを検索し、改めて検索、をエラーがなくなるまで行う。
# ファイル冒頭に "uniprot_id" が書かれていない場合に、エラーと判断する。
echo "エラーチェック。" >&2
ERROR_FILES=$(find ${WORKDIR} -type f -exec sh -c '(head -1 {} | grep -m 1 -q "^\"uniprot_id\"") || basename {} .txt' \;)
while true; do
  if [ -n "$ERROR_FILES" ]; then
     echo -n $ERROR_FILES | xargs -P20 -i -d ' ' sh $GET_SCRIPT ${WORKDIR}/{}.txt $ENDPOINT "{}"
     ERROR_FILES=$(for f in $ERROR_FILES; do echo ${WORKDIR}/${f}.txt; done | xargs -i sh -c '(head -1 {} | grep -m 1 -q "^\"uniprot_id\"") || basename {} .txt')
     sleep 5
  else
     break
  fi
done

# 100万件以上ヒットしているPfam IDを検索し、残りを漏れなく取得する。
echo "100万件以上Pfam ID毎にUniProt IDを取得。" >&2
find ${WORKDIR} -type f -exec sh $CHECK_SCRIPT "{}" $ENDPOINT $LIMIT \;

# 重複を除去するなど出力形式を整えて標準出力に。
echo "結果を標準出力に。" >&2
find ${WORKDIR} -type f -exec sh $FORMAT_SCRIPT "{}" \;
