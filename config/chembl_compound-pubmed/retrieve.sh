#!/bin/sh
set -euo pipefail

# 2021/04/13時点で1412640件あるので、200万件を超えた場合は最後の行のコメントアウトを取る必要あり。

curl -sSH "Accept: text/tab-separated-values" --data-urlencode query="PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#> PREFIX bibo: <http://purl.org/ontology/bibo/> SELECT ?chembl_id (substr(str(?pubmed),31) as ?pubmed_id) { SELECT DISTINCT ?chembl_id ?pubmed FROM <http://rdf.ebi.ac.uk/dataset/chembl> { [ a cco:SmallMolecule ; cco:chemblId ?chembl_id ; cco:hasDocument / bibo:pmid ?pubmed ] . } offset 0 limit 1000000 }" https://integbio.jp/rdf/mirror/ebi/sparql | tail -n +2 | sed -e 's/"//g'
curl -sSH "Accept: text/tab-separated-values" --data-urlencode query="PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#> PREFIX bibo: <http://purl.org/ontology/bibo/> SELECT ?chembl_id (substr(str(?pubmed),31) as ?pubmed_id) { SELECT DISTINCT ?chembl_id ?pubmed FROM <http://rdf.ebi.ac.uk/dataset/chembl> { [ a cco:SmallMolecule ; cco:chemblId ?chembl_id ; cco:hasDocument / bibo:pmid ?pubmed ] . } offset 1000000 limit 1000000 }" https://integbio.jp/rdf/mirror/ebi/sparql | tail -n +2 | sed -e 's/"//g'
#curl -sSH "Accept: text/tab-separated-values" --data-urlencode query="PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#> PREFIX bibo: <http://purl.org/ontology/bibo/> SELECT ?chembl_id (substr(str(?pubmed),31) as ?pubmed_id) { SELECT DISTINCT ?chembl_id ?pubmed FROM <http://rdf.ebi.ac.uk/dataset/chembl> { [ a cco:SmallMolecule ; cco:chemblId ?chembl_id ; cco:hasDocument / bibo:pmid ?pubmed ] . } offset 2000000 limit 1000000 }" https://integbio.jp/rdf/mirror/ebi/sparql | tail -n +2 | sed -e 's/"//g'
