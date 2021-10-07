#!/bin/bash
set -eo pipefail

# 引数一覧
# $1 : ファイル出力ディレクトリ [初期値なし]
# $2 : クエリ [初期値なし]
# $3 : 拡張子（content-type）["ttl"]
# $4 : エンドポイントURL [ https://integbio.jp/rdf/pubchem/sparql ]
# $5 : 出力ファイル名 [ uuidgenの出力 ]

CURL=/usr/bin/curl

declare -A ctype
ctype["ttl"]="text/turtle"
ctype["nt"]="application/n-triples"
ctype["tsv"]="text/tab-separated-values"

directory=$1
ext=$3
endpoint=$4
fn=$5
if [ -z $endpoint ]; then
  endpoint=https://integbio.jp/rdf/pubchem/sparql
fi
if [ -z $ext ]; then ext="ttl"; fi
if [ -z $fn ]; then fn=$(uuidgen); fi
content_type=${ctype[$ext]}
$CURL -sSH "Accept: ${content_type}" --data-urlencode query="$2" -o ${directory}/${fn}.${ext} ${endpoint}
#(test -e ${directory}/${fn}.${ext} && (head -1 ${directory}/${fn}.${ext} | grep -Pq "^(?:@prefix|# Empty (?:NT|TURTLE)|<https?:)")) || echo "$2" > ${directory}/${fn}.err
