#!/bin/bash
set -eux
../sparql_tsv.sh mondo_labels.rq https://rdfportal.org/bioportal/sparql > mondo_labels.tsv
awk -F "\t" '$2~/#label$/{print $3 "\t" $1}' mondo_labels.tsv > mondo_label.tsv
awk -F "\t" '$2~/#hasRelatedSynonym$/{print $3 "\t" $1}' mondo_labels.tsv > mondo_related_synonym.tsv
awk -F "\t" '$2~/#hasBroadSynonym$/{print $3 "\t" $1}' mondo_labels.tsv > mondo_broad_synonym.tsv
awk -F "\t" '$2~/#hasExactSynonym$/{print $3 "\t" $1}' mondo_labels.tsv > mondo_exact_synonym.tsv