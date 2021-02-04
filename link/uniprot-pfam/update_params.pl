# Thread limit of SPARQL query
our $THREAD_LIMIT = 10;

# Endpoint
our $EP = "https://integbio.jp/rdf/mirror/uniprot/sparql";
our $EP_MIRROR = "https://sparql.uniprot.org/sparql";

# Pfam の種取得が重いので、全 Pfam ID 取得して、Pfam 毎にリストを取得

# SPARQL query for get-taxonomy-list
# memo: ?org は Pfam URI
our $QUERY_TAX = "PREFIX up: <http://purl.uniprot.org/core/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX db: <http://purl.uniprot.org/database/>
SELECT DISTINCT ?org
WHERE {
  ?org up:database db:Pfam .
}";

# SPARQL query for get-ID-list
# memo: __TAXON__ は Pfam URI
our $QUERY = "PREFIX up: <http://purl.uniprot.org/core/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX db: <http://purl.uniprot.org/database/>
SELECT DISTINCT ?source ?target
WHERE {
  VALUES ?target { <__TAXON__> }
  ?source a up:Protein ;
          rdfs:seeAlso ?target .
}";

# regex : req. double escape backslash (e.g. '\d' -> '\\d')
our $SOURCE_REGEX = "http://purl.uniprot.org/uniprot/(.+)";
our $TARGET_REGEX = "http://purl.uniprot.org/pfam/(.+)";
