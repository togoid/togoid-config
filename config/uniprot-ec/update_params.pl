# Thread limit of SPARQL query
our $THREAD_LIMIT = 10;

# Endpoint
our $EP = "https://integbio.jp/rdf/mirror/uniprot/sparql";
our $EP_MIRROR = "https://sparql.uniprot.org/sparql";

# SPARQL query for get-target-list
our $QUERY_TAX = "PREFIX up: <http://purl.uniprot.org/core/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX db: <http://purl.uniprot.org/database/>
SELECT DISTINCT ?target
WHERE {
  ?s up:component*/up:enzyme ?target . 
}";

# SPARQL query for get-ID-list
our $QUERY = "PREFIX up: <http://purl.uniprot.org/core/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX db: <http://purl.uniprot.org/database/>
SELECT DISTINCT ?source ?target
WHERE {
  VALUES ?target { <__TARGET__> }
  ?source a up:Protein ;
          up:component*/up:enzyme ?target .
}";

# regex : req. double escape backslash (e.g. '\d' -> '\\d')
our $SOURCE_REGEX = "http://purl.uniprot.org/uniprot/(.+)";
our $TARGET_REGEX = "http://purl.uniprot.org/enzyme/(.+)";
