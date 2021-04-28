#!/usr/bin/sh
set -euo pipefail

ENDPOINT=https://integbio.jp/rdf/mirror/uniprot/sparql
WORKDIR=pfam2uniprot # 一時的にPfamID毎のUniProtIDリストファイルを保存するディレクトリ
LIMIT=1000000 # SPARQLエンドポイントにおける取得可能データ件数の最大値

if [ ! -e $WORKDIR ]; then mkdir $WORKDIR ; fi
ls ${WORKDIR}/*.txt &> /dev/null
if [ $? = 0 ]; then rm ${WORKDIR}/*; fi

# Pfam IDのリストを取得。
curl -sSH 'Accept: text/tab-separated-values' --data-urlencode query@get_pfam_id.rq $ENDPOINT | grep -o 'PF[0-9]*' > pfam_id_list.txt

# Pfam ID毎にUniProt IDを取得。
cat pfam_id_list.txt | xargs -P20 -i sh -c "QUERY=\$(sed -e 's/__PFAM_ID__/{}/' get_uniprot_pfam_list_pfam.rq); curl -o ${WORKDIR}/{}.txt -sSH 'Accept: text/tab-separated-values' --data-urlencode query=\"\${QUERY}\" $ENDPOINT"

# 100万件以上ヒットしているPfam IDを検索し、残りを漏れなく取得する。
find ${WORKDIR} -type f -exec sh count_check_and_query.sh "{}" $ENDPOINT $LIMIT \;

# 重複を除去するなど出力形式を整えて標準出力に。
find ${WORKDIR} -type f -exec sh formatter.sh "{}" \;
