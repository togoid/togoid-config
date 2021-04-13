#!/bin/sh
set -euo pipefail

curl -sSH "Accept: text/tab-separated-values" --data-urlencode query="PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#> SELECT ?chembl_id (substr(str(?pubchem),42) as ?pubchem_id) { SELECT DISTINCT ?chembl_id ?pubchem FROM <http://rdf.ebi.ac.uk/dataset/chembl> WHERE { [ a cco:SmallMolecule ; cco:chemblId ?chembl_id ; cco:moleculeXref ?pubchem ] . ?pubchem a cco:PubchemRef . } offset 0 limit 1000000 }" https://integbio.jp/rdf/mirror/ebi/sparql | tail -n +2
curl -sSH "Accept: text/tab-separated-values" --data-urlencode query="PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#> SELECT ?chembl_id (substr(str(?pubchem),42) as ?pubchem_id) { SELECT DISTINCT ?chembl_id ?pubchem FROM <http://rdf.ebi.ac.uk/dataset/chembl> WHERE { [ a cco:SmallMolecule ; cco:chemblId ?chembl_id ; cco:moleculeXref ?pubchem ] . ?pubchem a cco:PubchemRef . } offset 1000000 limit 1000000 }" https://integbio.jp/rdf/mirror/ebi/sparql | tail -n +2
