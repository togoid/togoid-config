# Endpoint: https://integbio.jp/rdf/bioportal/sparql
PREFIX oboInOwl: <http://www.geneontology.org/formats/oboInOwl#>
SELECT DISTINCT ?do_id ?mesh_id
FROM <http://integbio.jp/rdf/mirror/bioportal/doid>
WHERE {
  ?do_uri 
    oboInOwl:hasDbXref ?mesh ;
    oboInOwl:id ?do .
  FILTER (strstarts(?mesh,'MESH'))
  BIND (replace(str(?mesh), "MESH:", "") AS ?mesh_id)
  BIND (replace(str(?do), 'DOID:', '') AS ?do_id)
}
