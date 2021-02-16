-Bashを動かすと、IDのデータが取れると思います。
-エンドポイントはミラーを利用しています。

```
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX oboInOwl: <http://www.geneontology.org/formats/oboInOwl#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema>
SELECT DISTINCT ((?s)AS ?ORDO_ID) (STR(?id) AS ?ID)
FROM <http://integbio.jp/rdf/mirror/bioportal/doid>
WHERE {
  ?s oboInOwl:hasDbXref ?id.
   FILTER(contains(?id,'MESH'))
        }
```