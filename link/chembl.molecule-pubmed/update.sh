#!/bin/sh
# SPARQL query
QUERY="PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>
PREFIX bibo: <http://purl.org/ontology/bibo/>
SELECT ?molecule  (replace(str(?pubmed), "http://identifiers.org/pubmed/", "") as ?pubmed_id) 
WHERE{
  ?s  a cco:SmallMolecule ;
      cco:chemblId ?molecule ;
      cco:hasDocument ?ChemblDocument .
  ?ChemblDocument a cco:Document .
  ?ChemblDocument bibo:pmid ?pubmed .
  }
ORDER BY ?molecule"
# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" https://integbio.jp/rdf/mirror/ebi/sparql | sed -e 's/\"//g;  s/,/\t/g' | sed -e '1d' > link.tsv