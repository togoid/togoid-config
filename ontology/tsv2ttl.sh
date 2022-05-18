#!/bin/sh

gawk -f generate-togoid-ontology.awk class.tsv dataset.tsv property.tsv > togoid-ontology.ttl
