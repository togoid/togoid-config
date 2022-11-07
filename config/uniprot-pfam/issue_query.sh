#!/usr/bin/bash
set -euo pipefail
TARGET=$1
ENDPOINT=$2
PFAM_ID=$3
CURL=/usr/bin/curl
UNIPROT_PFAM_QUERY_FILE=get_uniprot_pfam_list_pfam.rq

#echo $TARGET
#echo $ENDPOINT
#echo $PFAM_ID

while true; do
  QUERY=$(sed -e "s/__PFAM_ID__/${PFAM_ID}/" $UNIPROT_PFAM_QUERY_FILE)
  $CURL -o ${TARGET} -sSH 'Accept: text/tab-separated-values' --data-urlencode query="${QUERY}" $ENDPOINT
  if [ $? -ne 0 ]; then
    echo "curlがエラー終了しました。実行を繰り返します。" >&2
    sleep 5
  else
    break
  fi
done
