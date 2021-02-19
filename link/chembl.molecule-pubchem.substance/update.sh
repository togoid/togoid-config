#!/bin/sh
# SPARQL query
QUERY='PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT (replace(str(?molecule), "http://rdf.ebi.ac.uk/resource/chembl/molecule/", "") as ?chembl_id) (replace(str(?pubchem), "http://pubchem.ncbi.nlm.nih.gov/substance/", "") as ?pubchem_substance_id) 
WHERE{
  ?molecule  a cco:SmallMolecule ;
      cco:moleculeXref ?pubchem .
  FILTER(CONTAINS(STR(?pubchem), "pubchem.ncbi.nlm.nih.gov/substance/"))
  }
ORDER BY ?chembl_id'  
# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" https://integbio.jp/rdf/mirror/ebi/sparql | sed -e 's/\"//g;  s/,/\	/g' | sed -e '1d' > link.tsv