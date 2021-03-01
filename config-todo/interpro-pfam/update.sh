#!/bin/sh

TMPDIR='/data/togoid/cache/interpro'
XML_PATH='ftp://ftp.ebi.ac.uk/pub/databases/interpro/interpro.xml.gz'
XML_GZ_FILENAME='interpro.xml.gz'
XML_FILENAME='interpro.xml'
ALL_PAIRS_FILENAME='ipr_all_pairs.tsv'

if [ $# -ne 1 ]; then
  echo "usage: ./update.sh DB_NAME" 1>&2
  exit 1
fi
DB_NAME=$1

OLD_FILE_SIZE=$(ls -l $TMPDIR/$XML_GZ_FILENAME | awk '{print $5}')
CURRENT_FILE_SIZE=$(curl -sI $XML_PATH | grep 'Content-Length' | tr -d '\r' | awk '{print $2}')

if [ ! -e $TMPDIR/$XML_GZ_FILENAME ] || [ ${OLD_FILE_SIZE} -ne ${CURRENT_FILE_SIZE} ]; then
    mkdir -p $TMPDIR
    curl -sS $XML_PATH > $TMPDIR/$XML_GZ_FILENAME
    gunzip -f -k $TMPDIR/$XML_GZ_FILENAME
    python ../interpro-pfam/interpro_xml_parse.py $TMPDIR/$XML_FILENAME > $TMPDIR/$ALL_PAIRS_FILENAME
fi

awk -F '\t' -v db=$DB_NAME '$2==db{print $1 "\t" $3}' $TMPDIR/$ALL_PAIRS_FILENAME
