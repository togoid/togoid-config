#!/bin/sh
# Require: ls, gzip, head, tr, sed, awk ,sort ,uniq, echo

# Ensembl Genome (Plants, Metazoa, Protists, Fungi, Bacteria) の TSV から ID 抽出
# ensembl_xxx_gene (source) to other dataset (target)


DIR=$1    # file dir. e.g. ${TOGOID_ROOT}/input/ensembl_genomes
SRC=$2    # dataset list:
          #     ensembl_gene
          #     ensembl_transcript
          #     ensembl_protein
TRG=$3    # dataset list:
          #     (ensembl_gene)
          #     ensembl_transcript
          #     ensembl_protein
          #     ncbigene
          #     renfeq_rna
          #     refseq_protein
          #     uniprot

if [ -z "$TRG" ] || [ $SRC = $TRG ] ; then
    echo argv error: script.sh [ensembl_genomes dir] [source] [target]
    exit 0
fi

# set source colomn number
SRC_COL1=1      # *.[entrez, refseq, uniprot].tsv.gz
SRC_COL2=3      # *.ena.tsv.gz
if [ $SRC = "ensembl_transcript" ] ; then
    SRC_COL1=2
    SRC_COL2=4
elif [ $SRC = "ensembl_protein" ] ; then
    SRC_COL1=3
    SRC_COL2=5
fi

# ourput
DBS=("plants" "metazoa" "protists" "fungi" "bacteria")
for SUB in ${DBS[@]}
do
    # get species
    ORGS=($(cd ${DIR}/${SUB}; ls | cut -f1 -d.| uniq))

    if [ $TRG = "ensembl_gene" ] ; then
	for ORG in ${ORGS[@]}
	do
	    ( gzip -dc ${DIR}/${SUB}/${ORG}.*.ena.tsv.gz 2>/dev/null | sed 1d | awk -v src=$(echo ${SRC_COL2}) '{ if ($3) { printf "%s\t%s\n", $src, $3 } }'; \
	      gzip -dc ${DIR}/${SUB}/${ORG}.*.entrez.tsv.gz 2>/dev/null | sed 1d | awk -v src=$(echo ${SRC_COL1}) '{ if ($1) { printf "%s\t%s\n", $src, $1 } }'; \
	      gzip -dc ${DIR}/${SUB}/${ORG}.*.refseq.tsv.gz 2>/dev/null | sed 1d | awk -v src=$(echo ${SRC_COL1}) '{ if ($1) { printf "%s\t%s\n", $src, $1 } }'; \
	      gzip -dc ${DIR}/${SUB}/${ORG}.*.uniprot.tsv.gz 2>/dev/null | sed 1d | awk -v src=$(echo ${SRC_COL1}) '{ if ($1) { printf "%s\t%s\n", $src, $1 } }'; ) | sort | uniq
	done
    elif [ $TRG = "ensembl_transcript" ] ; then
	for ORG in ${ORGS[@]}
	do
	    ( gzip -dc ${DIR}/${SUB}/${ORG}.*.ena.tsv.gz 2>/dev/null | sed 1d | awk -v src=$(echo ${SRC_COL2}) '{ if ($4) { printf "%s\t%s\n", $src, $4 } }'; \
	      gzip -dc ${DIR}/${SUB}/${ORG}.*.entrez.tsv.gz 2>/dev/null | sed 1d | awk -v src=$(echo ${SRC_COL1}) '{ if ($2) { printf "%s\t%s\n", $src, $2 } }'; \
	      gzip -dc ${DIR}/${SUB}/${ORG}.*.refseq.tsv.gz 2>/dev/null | sed 1d | awk -v src=$(echo ${SRC_COL1}) '{ if ($2) { printf "%s\t%s\n", $src, $2 } }'; \
	      gzip -dc ${DIR}/${SUB}/${ORG}.*.uniprot.tsv.gz 2>/dev/null | sed 1d | awk -v src=$(echo ${SRC_COL1}) '{ if ($2) { printf "%s\t%s\n", $src, $2 } }'; ) | sort | uniq
	done
    elif [ $TRG = "ensembl_protein" ] ; then
	for ORG in ${ORGS[@]}
     	do
	    ( gzip -dc ${DIR}/${SUB}/${ORG}.*.ena.tsv.gz 2>/dev/null | sed 1d | awk -v src=$(echo ${SRC_COL2}) '{ if ($5) { printf "%s\t%s\n", $src, $5 } }'; \
	      gzip -dc ${DIR}/${SUB}/${ORG}.*.entrez.tsv.gz 2>/dev/null | sed 1d | awk -v src=$(echo ${SRC_COL1}) '{ if ($3) { printf "%s\t%s\n", $src, $3 } }'; \
	      gzip -dc ${DIR}/${SUB}/${ORG}.*.refseq.tsv.gz 2>/dev/null | sed 1d | awk -v src=$(echo ${SRC_COL1}) '{ if ($3) { printf "%s\t%s\n", $src, $3 } }'; \
	      gzip -dc ${DIR}/${SUB}/${ORG}.*.uniprot.tsv.gz 2>/dev/null | sed 1d | awk -v src=$(echo ${SRC_COL1}) '{ if ($3) { printf "%s\t%s\n", $src, $3 } }'; ) | sort | uniq
	done
    elif [ $TRG = "ncbigene" ] ; then
	for ORG in ${ORGS[@]}
	do
	    gzip -dc ${DIR}/${SUB}/${ORG}.*.entrez.tsv.gz 2>/dev/null | sed 1d | awk -v src=$(echo ${SRC_COL1}) '{ if ($4 && $5 ~ "EntrezGene") { printf "%s\t%s\n", $src, $4 } }' | sort | uniq
	done
    elif [ $TRG = "refseq_rna" ] ; then
	for ORG in ${ORGS[@]}
	do
	    gzip -dc ${DIR}/${SUB}/${ORG}.*.refseq.tsv.gz 2>/dev/null | sed 1d | awk -v src=$(echo ${SRC_COL1}) '{ if ($4 && $5 ~ "RefSeq_dna") { printf "%s\t%s\n", $src, $4 } }' | sed  -r 's/\.[0-9]+$//g' | sort | uniq
	done
    elif [ $TRG = "refseq_protein" ] ; then
	for ORG in ${ORGS[@]}
	do
	    gzip -dc ${DIR}/${SUB}/${ORG}.*.refseq.tsv.gz 2>/dev/null | sed 1d | awk -v src=$(echo ${SRC_COL1}) '{ if ($4 && $5 ~ "RefSeq_peptide") { printf "%s\t%s\n", $src, $4 } }' | sed  -r 's/\.[0-9]+$//g' | sort | uniq
	done
    elif [ $TRG = "uniprot" ] ; then
	for ORG in ${ORGS[@]}
	do
	    gzip -dc ${DIR}/${SUB}/${ORG}.*.uniprot.tsv.gz 2>/dev/null | sed 1d | awk -v src=$(echo ${SRC_COL1}) '{ if ($4 && $5 ~ "Uniprot") { printf "%s\t%s\n", $src, $4 } }' | sort | uniq
	done
    fi
done
