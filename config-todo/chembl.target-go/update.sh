#!/bin/sh
# SPARQL query
QUERY="PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>
SELECT ?chembltarget ?go
WHERE{
  ?ChemblTargetcomponent a cco:TargetComponent .
  ?ChemblTargetcomponent cco:targetCmptXref ?go_uri .
  FILTER regex (?go_uri, "GO", "i") .
  
  BIND (REPLACE(STR(?ChemblTargetcomponent), 'http://rdf.ebi.ac.uk/resource/chembl/targetcomponent/', '') AS ?chembltarget)
  BIND (REPLACE(STR(?go_uri), 'http://identifiers.org/obo.go/', '') AS ?go)
  }
  ORDER BY ?chembltarget"
# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" https://integbio.jp/rdf/mirror/ebi/sparql | sed -e 's/\"//g;  s/,/\t/g' | sed -e '1d' > pair.tsv
