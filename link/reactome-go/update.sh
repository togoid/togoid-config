# 20210204 moriya

# SPARQL query
QUERY="PREFIX biopax: <http://www.biopax.org/release/biopax-level3.owl#> \
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> \
SELECT DISTINCT ?reactome ?go \
FROM <http://rdf.ebi.ac.uk/dataset/reactome> \
WHERE { \
  ?path biopax:xref [ \
    biopax:db 'Reactome'^^xsd:string ; \
    biopax:id ?reactome \
  ] ; \
        biopax:xref [ \
    biopax:db 'GENE ONTOLOGY'^^xsd:string ; \
    biopax:id ?go \
  ] . \
}"

# url encode
ENCODE=`echo $QUERY | nkf -WwMQ | sed 's/=$//g' | tr = % | tr -d '\n'`

# curl post -> format -> delete header
curl -X POST -H "Accept: text/csv" -d "query=$ENCODE" https://integbio.jp/rdf/mirror/ebi/sparql | sed -e 's/\"//g; s/,/\t/g; s/GO:/GO_/g' | sed -n 2,\$p

