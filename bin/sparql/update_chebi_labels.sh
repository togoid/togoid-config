#!/bin/bash
set -eux
../sparql_tsv.sh chebi_labels.rq https://rdfportal.org/ebi/sparql > chebi_labels.tsv
awk -F "\t" '$2~/#label$/{print $3 "\t" $1}' chebi_labels.tsv > chebi_label.tsv
awk -F "\t" '$2~/#hasRelatedSynonym$/{print $3 "\t" $1}' chebi_labels.tsv > chebi_related_synonym.tsv
awk -F "\t" '$2~/#hasExactSynonym$/{print $3 "\t" $1}' chebi_labels.tsv > chebi_exact_synonym.tsv