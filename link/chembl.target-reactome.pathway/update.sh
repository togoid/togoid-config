#!/bin/sh
# SPARQL query
QUERY="PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>
SELECT   ?moleculeid ?reactome_id
WHERE{
  ?mechanism a cco:Mechanism ;
     cco:hasTarget ?target ;
     cco:hasMolecule ?molecule .
  ?target cco:hasTargetComponent ?component .
  ?component cco:targetCmptXref ?reactome .
  FILTER(CONTAINS(STR(?reactome), "reactome"))
  BIND (REPLACE(STR(?reactome), 'http://identifiers.org/reactome/', '') AS ?reactome_id)
  ?molecule cco:chemblId ?moleculeid .
  }
ORDER BY ?moleculeid"
# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" https://integbio.jp/rdf/mirror/ebi/sparql | sed -e 's/\"//g;  s/,/\t/g' | sed -e '1d' > pair.tsv
