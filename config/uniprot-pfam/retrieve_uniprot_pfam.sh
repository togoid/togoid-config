#!/usr/bin/sh
set -euo pipefail

ENDPOINT=https://integbio.jp/rdf/mirror/uniprot/sparql
WORKDIR=pfam2uniprot # 一時的にPfamID毎のUniProtIDリストファイルを保存するディレクトリ
LIMIT=1000000 # SPARQLエンドポイントにおける取得可能データ件数の最大値
CURL=/usr/bin/curl

# Pfam ID単位で対応するUniProt IDを取得するクエリのテンプレート。
# __PFAM_ID__ と書かれている部分を、実際のPfam ID（ex. PF00201）で置換する。
QUERY_FILE=get_uniprot_pfam_list_pfam.rq

if [ ! -e $WORKDIR ]; then mkdir $WORKDIR ; fi
ls ${WORKDIR}/*.txt &> /dev/null
if [ $? = 0 ]; then rm ${WORKDIR}/*; fi

# Pfam IDのリストを取得。
$CURL -sSH 'Accept: text/tab-separated-values' --data-urlencode query@get_pfam_id.rq $ENDPOINT | grep -o 'PF[0-9]*' > pfam_id_list.txt

# Pfam ID毎にUniProt IDを取得。
cat pfam_id_list.txt | xargs -P20 -i sh -c "QUERY=\$(sed -e 's/__PFAM_ID__/{}/' $QUERY_FILE); $CURL -o ${WORKDIR}/{}.txt -sSH 'Accept: text/tab-separated-values' --data-urlencode query=\"\${QUERY}\" $ENDPOINT"

# エラー終了しているファイルを検索し、改めて検索、をエラーがなくなるまで行う。
# ファイル冒頭に "uniprot_id" が書かれていない場合に、エラーと判断する。
while true; do 
  ERROR_FILES=$(find ${WORKDIR} -type f -exec sh -c 'grep -q "^\"uniprot_id\"" {} || basename {} .txt' \;)
  if [ -n "$ERROR_FILES" ]; then
     echo -n $ERROR_FILES | xargs -P20 -i -d ' ' sh -c "QUERY=\$(sed -e 's/__PFAM_ID__/{}/' $QUERY_FILE); $CURL -o ${WORKDIR}/{}.txt -sSH 'Accept: text/tab-separated-values' --data-urlencode query=\"\${QUERY}\" $ENDPOINT"
  else
     break
  fi
done

# 100万件以上ヒットしているPfam IDを検索し、残りを漏れなく取得する。
find ${WORKDIR} -type f -exec sh count_check_and_query.sh "{}" $ENDPOINT $LIMIT \;

# 重複を除去するなど出力形式を整えて標準出力に。
find ${WORKDIR} -type f -exec sh formatter.sh "{}" \;
