#!/usr/bin/bash
set -euo pipefail

# PubChem IDとInChiIKey IDのペアを取得する。

WGET=/usr/bin/wget
GZIP=/usr/bin/gzip

$WGET -qO - https://ftp.ncbi.nlm.nih.gov/pubchem/Compound/Extras/CID-InChI-Key.gz | $GZIP -dc | cut -f1,3
