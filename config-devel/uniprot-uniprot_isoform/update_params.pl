# Thread limit of SPARQL query
our $THREAD_LIMIT = 10;

# Endpoint
our $EP = "https://integbio.jp/rdf/uniprot/sparql";
our $EP_MIRROR = "https://sparql.uniprot.org/sparql";

# SPARQL query for get-target-list
our $QUERY_TAX = "PREFIX up: <http://purl.uniprot.org/core/>
SELECT DISTINCT ?org
WHERE {
  ?s a up:Protein ;
     up:reviewed 1 ;
     up:organism ?org .
}";

# SPARQL query for get-ID-list
our $QUERY = "PREFIX up: <http://purl.uniprot.org/core/>
SELECT DISTINCT ?source ?target
WHERE {
  ?source a up:Protein ;
          up:organism <__TAXON__> .
  OPTIONAL {
    ?source up:sequence ?target_temp .
  }
  BIND(IF(bound(?target_temp), ?target_temp, URI(REPLACE(STR(?source), \"uniprot/\", \"isoforms/\"))) AS ?target)
}";

# regex : req. double escape backslash (e.g. '\d' -> '\\d')
our $SOURCE_REGEX = "http://purl.uniprot.org/uniprot/(.+)";
our $TARGET_REGEX = "http://purl.uniprot.org/isoforms/(.+)";

1;
