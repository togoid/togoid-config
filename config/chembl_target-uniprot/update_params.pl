# Thread limit of SPARQL query
our $THREAD_LIMIT = 10;

# Endpoint
our $EP = "https://rdfportal.org/ebi/sparql";
our $EP_MIRROR = undef;

# SPARQL query for get-taxonomy-list
our $QUERY_TAX = "PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>
SELECT DISTINCT ?org
FROM <http://rdf.ebi.ac.uk/dataset/chembl>
WHERE {
  ?org ^cco:taxonomy [ 
    a cco:SingleProtein ;
    cco:hasAssay/cco:hasActivity/cco:hasMolecule [ 
      a cco:SmallMolecule 
    ] ] .
  FILTER (REGEX (?org, 'identifiers.org'))
}";

# SPARQL query for get-ID-list
our $QUERY = "PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
SELECT DISTINCT ?chembl_target as ?source ?uniprot as ?target
FROM <http://rdf.ebi.ac.uk/dataset/chembl>
WHERE {
  ?chembl_compound a cco:SmallMolecule ;
          cco:hasActivity/cco:hasAssay/cco:hasTarget ?chembl_target .
  ?chembl_target a cco:SingleProtein ;
          cco:taxonomy <__TAXON__> ;
          skos:exactMatch/skos:exactMatch ?uniprot.
}";

# regex : req. double escape backslash (e.g. '\d' -> '\\d')
our $SOURCE_REGEX = "http://rdf.ebi.ac.uk/resource/chembl/target/(.+)";
our $TARGET_REGEX = "http://purl.uniprot.org/uniprot/(.+)";
