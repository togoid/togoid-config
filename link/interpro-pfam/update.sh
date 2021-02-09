#!/bin/sh

IPR_ALL_PAIRS_FILE='ipr_all_pairs.tsv'
DIR=`pwd`

if [ $# -ne 1 ]; then
  echo "usage: ./update.sh DB_NAME" 1>&2
  exit 1
fi
DB_NAME=$1

cd ../interpro-pfam
if [ ! -e $IPR_ALL_PAIRS_FILE ]; then
    wget ftp://ftp.ebi.ac.uk/pub/databases/interpro/interpro.xml.gz
    gunzip interpro.xml.gz
    python interpro_xml_parse.py interpro.xml > $IPR_ALL_PAIRS_FILE
fi

cd $DIR
awk -F '\t' -v db=$DB_NAME '$2==db{print $1 "\t" $3}' ../interpro-pfam/$IPR_ALL_PAIRS_FILE
