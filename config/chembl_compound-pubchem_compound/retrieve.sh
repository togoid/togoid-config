#!/bin/sh
set -euo pipefail

# 2021/04/13時点で1877743件あるので、200万件を超えた場合は最後の行のコメントアウトを取る必要あり。

curl -sSH "Accept: text/tab-separated-values" --data-urlencode query="PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#> SELECT ?chembl_id (substr(str(?pubchem),42) as ?pubchem_id) { SELECT DISTINCT ?chembl_id ?pubchem FROM <http://rdf.ebi.ac.uk/dataset/chembl> WHERE { [ a cco:SmallMolecule ; cco:chemblId ?chembl_id ; cco:moleculeXref ?pubchem ] . ?pubchem a cco:PubchemRef . } offset 0 limit 1000000 }" https://integbio.jp/rdf/mirror/ebi/sparql | tail -n +2
curl -sSH "Accept: text/tab-separated-values" --data-urlencode query="PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#> SELECT ?chembl_id (substr(str(?pubchem),42) as ?pubchem_id) { SELECT DISTINCT ?chembl_id ?pubchem FROM <http://rdf.ebi.ac.uk/dataset/chembl> WHERE { [ a cco:SmallMolecule ; cco:chemblId ?chembl_id ; cco:moleculeXref ?pubchem ] . ?pubchem a cco:PubchemRef . } offset 1000000 limit 1000000 }" https://integbio.jp/rdf/mirror/ebi/sparql | tail -n +2
#curl -sSH "Accept: text/tab-separated-values" --data-urlencode query="PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#> SELECT ?chembl_id (substr(str(?pubchem),42) as ?pubchem_id) { SELECT DISTINCT ?chembl_id ?pubchem FROM <http://rdf.ebi.ac.uk/dataset/chembl> WHERE { [ a cco:SmallMolecule ; cco:chemblId ?chembl_id ; cco:moleculeXref ?pubchem ] . ?pubchem a cco:PubchemRef . } offset 2000000 limit 1000000 }" https://integbio.jp/rdf/mirror/ebi/sparql | tail -n +2
