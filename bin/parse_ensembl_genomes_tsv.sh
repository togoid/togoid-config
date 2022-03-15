#!/bin/sh
# Require: ls, gzip, head, tr, sed, awk ,sort ,uniq, echo

# Ensembl Genome (Plants, Metazoa, Protists, Fungi, Bacteria) の TSV から ID 抽出
# ensembl_xxx_gene (source) to other dataset (target)


DIR=$1        # file dir. e.g. ${TOGOID_ROOT}/ensembl_genomes/plants
DATASET=$2    # dataset list:
              #     ensembl_transcript
              #     ensembl_protein
              #     ncbigene
              #     renfeq_rna
              #     refseq_protein
              #     uniprot

SRC="gene_stable_id"  # source colomn label
DB="db_name"          # database colomn label
DB_NAME=""            # database name for filtering
RM_TRG_VER=0          # remove flag of target-ID-version-number
CHK=""

# check target dataset
if [ $DATASET = "ensembl_transcript" ] ; then
  POSTFIX="ena"
  TRG="transcript_stable_id"
elif [ $DATASET = "ensembl_protein" ] ; then
  POSTFIX="ena"
  TRG="protein_stable_id"
  CHK="transcript_stable_id"
elif [ $DATASET = "ncbigene" ] ; then
  POSTFIX="entrez"
  TRG="xref"
  DB_NAME="EntrezGene"
elif [ $DATASET = "refseq_rna" ] ; then
  POSTFIX="refseq"
  TRG="xref"
  DB_NAME="RefSeq_dna"
  RM_TRG_VER=1
elif [ $DATASET = "refseq_protein" ] ; then
  POSTFIX="refseq"
  TRG="xref"
  DB_NAME="RefSeq_peptide"
  RM_TRG_VER=1
elif [ $DATASET = "uniprot" ] ; then
  POSTFIX="uniprot"
  TRG="xref"
  DB_NAME="Uniprot"
fi
    
# get file list
FILES=($(ls ${DIR}/*.${POSTFIX}.tsv.gz))

# get source/target column from 1st file
I=0
HEADER=($(gzip -dc ${FILES[0]} | head -n 1 | tr "\t" "\n"))
for COL in ${HEADER[@]}
do
  I=$(expr $I + 1)
  if [ $COL = $SRC ] ; then
    SRC_COL=$I
  fi
  if [ $COL = $TRG ] ; then
    TRG_COL=$I
  fi
  if [ $COL = $DB ] ; then
    DB_COL=$I
  fi
  if [ $COL = $CHK ] ; then
    CHK_COL=$I
  fi
done
    
# output
for FILE in ${FILES[@]}
  do
  if [ $DB_NAME ] && [ $RM_TRG_VER -eq 1 ] ; then
    # check DB name & remove version number (refseq_rna, refseq_protein)
    gzip -dc ${FILE} | sed 1d | awk -v src=$(echo ${SRC_COL}) -v trg=$(echo ${TRG_COL}) -v db=$(echo ${DB_COL}) -v name=${DB_NAME} '{ if ($trg && $db ~ name) { printf "%s\t%s\n", $src, $trg } }' | sed -r 's/\.[0-9]+$//g' | sort | uniq
  elif [ $DB_NAME ] ; then
    # check DB name (ncbigene, uniprot)
    gzip -dc ${FILE} | sed 1d | awk -v src=$(echo ${SRC_COL}) -v trg=$(echo ${TRG_COL}) -v db=$(echo ${DB_COL}) -v name=${DB_NAME} '{ if ($trg && $db ~ name) { printf "%s\t%s\n", $src, $trg } }' | sort | uniq
  elif [ $RM_TRG_VER -eq 1 ] ; then
    # remove version number (-)
    gzip -dc ${FILE} | sed 1d | awk -v src=$(echo ${SRC_COL}) -v trg=$(echo ${TRG_COL}) '{ if ($trg) { printf "%s\t%s\n", $src, $trg } }' | sed -r 's/\.[0-9]+$//g' | sort | uniq
  elif [ $CHK ] ; then
    # compare to transcript_id  (ensembl_protein)
    gzip -dc ${FILE} | sed 1d | awk -v src=$(echo ${SRC_COL}) -v trg=$(echo ${TRG_COL}) -v chk=$(echo ${CHK_COL}) '{ if ($trg && $src != $trg && $trg != $chk) { printf "%s\t%s\n", $src, $trg } }' | sort | uniq
  else
    # normal (ensembl_transcript)
    gzip -dc ${FILE} | sed 1d | awk -v src=$(echo ${SRC_COL}) -v trg=$(echo ${TRG_COL}) '{ if ($trg && $src != $trg) { printf "%s\t%s\n", $src, $trg } }' | sort | uniq
  fi
done
