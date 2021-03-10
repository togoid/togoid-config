# Endpoint: https://integbio.jp/rdf/bioportal/sparql
PREFIX oboInOwl: <http://www.geneontology.org/formats/oboInOwl#>
SELECT DISTINCT ?do_id ?omim_id
FROM <http://integbio.jp/rdf/mirror/bioportal/doid>
WHERE {
  ?do_uri 
    oboInOwl:hasDbXref ?omim ;
    oboInOwl:id ?do .
  FILTER (strstarts(?omim,'OMIM:'))
  BIND (replace(str(?omim), 'OMIM:', '') AS ?omim_id)
  BIND (replace(str(?do), 'DOID:', '') AS ?do_id)
}
