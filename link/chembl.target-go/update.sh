#!/bin/sh
# SPARQL query
QUERY="PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>
SELECT ?ChemblTargetcomponent ?go
WHERE{
  ?ChemblTargetcomponent a cco:TargetComponent .
  ?ChemblTargetcomponent cco:targetCmptXref ?go .
  FILTER regex (?go, "GO", "i") .
  }
  ORDER BY ?ChemblTargetcomponent"
# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" https://integbio.jp/rdf/mirror/ebi/sparql | sed -e 's/\"//g;  s/,/\t/g' | sed -e '1d' > pair.tsv
