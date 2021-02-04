# 20210204 moriya

# SPARQL query
QUERY="PREFIX biopax: <http://www.biopax.org/release/biopax-level3.owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
SELECT DISTINCT ?pathway ?reaction
FROM <http://rdf.ebi.ac.uk/dataset/reactome>
WHERE {
  VALUES ?reaction_type { biopax:BiochemicalReaction biopax:TemplateReaction biopax:Degradation }
  ?path a biopax:Pathway ;
        biopax:xref [
          biopax:db 'Reactome'^^xsd:string ;
          biopax:id ?pathway
        ] ;
        biopax:pathwayComponent+ ?react .
  ?react a ?reaction_type ;
        biopax:xref [ 
          biopax:db 'Reactome'^^xsd:string ;
          biopax:id ?reaction
        ] .
}"

# url encode
ENCODE=`echo $QUERY | nkf -WwMQ | sed 's/=$//g' | tr = % | tr -d '\n'`

# curl post -> format -> delete header
curl -X POST -H "Accept: text/csv" -d "query=$ENCODE" https://integbio.jp/rdf/mirror/ebi/sparql | sed -e 's/\"//g; s/,/\t/g' | sed -n 2,\$p

