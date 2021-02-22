#!/bin/sh
# SPARQL query
QUERY='PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT (replace(str(?molecule), "http://rdf.ebi.ac.uk/resource/chembl/molecule/", "") as ?chembl_id) (replace(str(?drugbank), "http://www.drugbank.ca/drugs/", "") as ?drugbank_id)
WHERE{
  ?molecule  a cco:SmallMolecule ;
      cco:moleculeXref ?drugbank .
  FILTER(CONTAINS(STR(?drugbank), "drugbank"))
  }
ORDER BY ?molecule'
# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" https://integbio.jp/rdf/mirror/ebi/sparql | sed -e 's/\"//g;  s/,/\	/g' | sed -e '1d' > link.tsv
