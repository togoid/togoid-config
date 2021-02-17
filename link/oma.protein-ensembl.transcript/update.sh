#!/bin/sh
# 20210217 hirokazu chiba, hiromasaono
# SPARQL query
QUERY="PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX lscr: <http://purl.org/lscr#>

SELECT ?omaprotein_id ?enst_id
WHERE {
  ?omaprotein orth:organism/obo:RO_0002162 <http://purl.uniprot.org/taxonomy/9606> .
  # RO_0002162 'in taxon'
  ?omaprotein lscr:xrefEnsemblTranscript ?enst .

  BIND (replace(str(?omaprotein), 'https://omabrowser.org/oma/info/', '') AS ?omaprotein_id)
  BIND (replace(str(?enst), 'http://rdf.ebi.ac.uk/resource/ensembl.transcript/', '') AS ?enst_id)
}
ORDER BY ?omaprotein"
# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" https://sparql.omabrowser.org/sparql/ | sed -e 's/\"//g;  s/,/\t/g' | sed -e '1d' > pair.tsv