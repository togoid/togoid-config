# Thread limit of SPARQL query
our $THREAD_LIMIT = 10;

# Endpoint
our $EP = "https://integbio.jp/rdf/sparql";
our $EP_MIRROR = "http://rdf.integbio.jp/dataset/pdbj";

# SPARQL query for get-taxonomy-list
our $QUERY_TAX = "
PREFIX pdbr: <https://rdf.wwpdb.org/pdb/>
PREFIX pdbo: <https://rdf.wwpdb.org/schema/pdbx-v50.owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT DISTINCT ?org
WHERE {
     ?protein pdbo:has_entityCategory/pdbo:has_entity/rdfs:seeAlso ?org .
     FILTER(REGEX(?org, 'taxonomy/'))
}";

# SPARQL query for get-ID-list
our $QUERY = "PREFIX pdbr: <https://rdf.wwpdb.org/pdb/>
PREFIX pdbo: <https://rdf.wwpdb.org/schema/pdbx-v50.owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT DISTINCT ?source ?target
WHERE {
      ?source pdbo:has_entityCategory ?ecats .
      ?ecats pdbo:has_entity ?entity .
      ?entity rdfs:seeAlso ?target . 
      ?entity rdfs:seeAlso <__TAXON__> .
      FILTER(REGEX(?target,'ec-code/'))
}";

# regex : req. double escape backslash (e.g. '\d' -> '\\d')
our $SOURCE_REGEX = "https://rdf.wwpdb.org/pdb/(.+)";
our $TARGET_REGEX = "http://identifiers.org/ec-code/(.+)";
