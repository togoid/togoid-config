#!/usr/bin/bash
set -euo pipefail
# 不必要な変数名および重引用符を除去するとともに、UniProt IDとPfam IDのペアを作って出力する。
# また、重複も除去する。
TARGET=$1
PFID=$(basename $1 .txt)
sed -ne "/^\"uniprot/ ! {s/\"$/\t${PFID}/;s/^\"//p}" $TARGET | sort -u --parallel=4
