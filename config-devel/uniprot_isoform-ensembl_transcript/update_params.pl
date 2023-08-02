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
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT DISTINCT ?source ?target
WHERE {
  ?protein a up:Protein ;
           up:organism <__TAXON__> ;
           up:sequence ?source .
  ?target a up:Transcript_Resource ;
          up:database <http://purl.uniprot.org/database/Ensembl> ;
          rdfs:seeAlso ?source .
}";

# regex : req. double escape backslash (e.g. '\d' -> '\\d')
our $SOURCE_REGEX = "http://purl.uniprot.org/isoforms/(.+)";
our $TARGET_REGEX = "http://rdf.ebi.ac.uk/resource/ensembl.transcript/(.+)";

1;
