#!/bin/sh
# SPARQL query
QUERY="PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>
SELECT ?chembl_id (replace(str(?chebi_2), "%3A", ":") as ?chebi_id) 
{select  (replace(str(?molecule), "http://rdf.ebi.ac.uk/resource/chembl/molecule/", "") as ?chembl_id) 
 (strafter(str(?chebi), "chebiId=")as ?chebi_2)
WHERE{
  ?molecule a cco:SmallMolecule ;
            cco:moleculeXref ?chebi .
  FILTER(CONTAINS(STR(?chebi), "chebi"))
  }}
ORDER BY ?chembl_id"
# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" https://integbio.jp/rdf/mirror/ebi/sparql | sed -e 's/\"//g;  s/,/\t/g' | sed -e '1d' > link.tsv
