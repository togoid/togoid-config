#!/bin/sh
# SPARQL query
QUERY="PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>
SELECT (replace(str(?molecule), "http://rdf.ebi.ac.uk/resource/chembl/molecule/", "") as ?chembl_id) (replace(str(?hmdb), "http://www.hmdb.ca/metabolites/", "") as ?hmdb_id) 
WHERE{
  ?molecule a cco:SmallMolecule ;
            cco:moleculeXref ?hmdb .
   FILTER(CONTAINS(STR(?hmdb), "hmdb"))
  }
ORDER BY ?molecule"
# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" https://integbio.jp/rdf/mirror/ebi/sparql | sed -e 's/\"//g;  s/,/\t/g' | sed -e '1d' > link.tsv