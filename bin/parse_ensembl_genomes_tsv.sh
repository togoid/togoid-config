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

# get species
ORGS=($(cd ${DIR}; ls | cut -f1 -d.| uniq))

if [ $DATASET = "ensembl_transcript" ] ; then
  for ORG in ${ORGS[@]}
  do
     ( gzip -dc ${DIR}/${ORG}.*.ena.tsv.gz 2>/dev/null | sed 1d | awk '{ if ($4) { printf "%s\t%s\n", $3, $4 } }'; \
       gzip -dc ${DIR}/${ORG}.*.entrez.tsv.gz 2>/dev/null | sed 1d | awk '{ if ($2) { printf "%s\t%s\n", $1, $2 } }'; \
       gzip -dc ${DIR}/${ORG}.*.refseq.tsv.gz 2>/dev/null | sed 1d | awk '{ if ($2) { printf "%s\t%s\n", $1, $2 } }'; \
       gzip -dc ${DIR}/${ORG}.*.uniprot.tsv.gz 2>/dev/null | sed 1d | awk '{ if ($2) { printf "%s\t%s\n", $1, $2 } }'; ) | sort | uniq
  done
elif [ $DATASET = "ensembl_protein" ] ; then
  for ORG in ${ORGS[@]}
  do
     ( gzip -dc ${DIR}/${ORG}.*.ena.tsv.gz 2>/dev/null | sed 1d | awk '{ if ($5) { printf "%s\t%s\n", $3, $5 } }'; \
       gzip -dc ${DIR}/${ORG}.*.entrez.tsv.gz 2>/dev/null | sed 1d | awk '{ if ($3) { printf "%s\t%s\n", $1, $3 } }'; \	 
       gzip -dc ${DIR}/${ORG}.*.refseq.tsv.gz 2>/dev/null | sed 1d | awk '{ if ($3) { printf "%s\t%s\n", $1, $3 } }'; \
       gzip -dc ${DIR}/${ORG}.*.uniprot.tsv.gz 2>/dev/null | sed 1d | awk '{ if ($3) { printf "%s\t%s\n", $1, $3 } }'; ) | sort | uniq
  done
elif [ $DATASET = "ncbigene" ] ; then
  for ORG in ${ORGS[@]}
  do
    gzip -dc ${DIR}/${ORG}.*.entrez.tsv.gz 2>/dev/null | sed 1d | awk '{ if ($4 && $5 ~ "EntrezGene") { printf "%s\t%s\n", $1, $4 } }' | sort | uniq
  done
elif [ $DATASET = "refseq_rna" ] ; then
  for ORG in ${ORGS[@]}
  do
    gzip -dc ${DIR}/${ORG}.*.refseq.tsv.gz 2>/dev/null | sed 1d | awk '{ if ($4 && $5 ~ "RefSeq_dna") { printf "%s\t%s\n", $1, $4 } }' | sed  -r 's/\.[0-9]+$//g' | sort | uniq
  done
elif [ $DATASET = "refseq_protein" ] ; then
  for ORG in ${ORGS[@]}
  do
    gzip -dc ${DIR}/${ORG}.*.refseq.tsv.gz 2>/dev/null | sed 1d | awk '{ if ($4 && $5 ~ "RefSeq_peptide") { printf "%s\t%s\n", $1, $4 } }' | sed  -r 's/\.[0-9]+$//g' | sort | uniq
  done
elif [ $DATASET = "uniprot" ] ; then
  for ORG in ${ORGS[@]}
  do
    gzip -dc ${DIR}/${ORG}.*.uniprot.tsv.gz 2>/dev/null | sed 1d | awk '{ if ($4 && $5 ~ "Uniprot") { printf "%s\t%s\n", $1, $4 } }' | sort | uniq
  done
fi
