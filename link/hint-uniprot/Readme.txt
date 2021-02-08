以下のSPARQLで取れます。

#HINTのIDと UniProtIDのペアを取る
#endpoint: http://sparql.med2rdf.org/sparql

PREFIX hnt: <http://purl.jp/10/hint/>
PREFIX bp3: <http://www.biopax.org/release/biopax-level3.owl#>
PREFIX uni: <http://identifiers.org/uniprot/>
PREFIX obo: <http://purl.obolibrary.org/obo/>

SELECT  (replace(str(?hint), "http://purl.jp/10/hint/", "") as ?hint_id)   (replace(str(?uniprot), "http://identifiers.org/uniprot/", "") as ?uniprot_id)
FROM <http://med2rdf.org/graph/hint> 
where {
   ?hint a bp3:MolecularInteraction ;
      bp3:participant / obo:BFO_0000051 ?uniprot .
  }
LIMIT 10