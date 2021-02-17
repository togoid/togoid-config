#!/bin/sh
# 20210217 hirokazu chiba, hiromasaono
# SPARQL query
QUERY="PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX lscr: <http://purl.org/lscr#>

SELECT ?omaprotein_id ?ensg_id
WHERE {
  ?omaprotein orth:organism/obo:RO_0002162 <http://purl.uniprot.org/taxonomy/9606> .
  ?omaprotein sio:SIO_010079/lscr:xrefEnsemblGene ?ensg .

  BIND (replace(str(?omaprotein), 'https://omabrowser.org/oma/info/', '') AS ?omaprotein_id)
  BIND (replace(str(?ensg), 'http://rdf.ebi.ac.uk/resource/ensembl/', '') AS ?ensg_id)
}
ORDER BY ?omaprotein"
# curl -> format -> delete header
curl -s -H "Accept: text/csv" --data-urlencode "query=$QUERY" https://sparql.omabrowser.org/sparql/ | sed -e 's/\"//g;  s/,/\t/g' | sed -e '1d' > pair.tsv