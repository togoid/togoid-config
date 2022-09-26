# Thread limit of SPARQL query
our $THREAD_LIMIT = 10;

# Endpoint
our $EP = "https://integbio.jp/rdf/ebi/sparql";
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
SELECT DISTINCT ?source ?target
FROM <http://rdf.ebi.ac.uk/dataset/chembl>
WHERE {
?source a cco:SmallMolecule ;
          cco:hasActivity/cco:hasAssay [
            a cco:Assay ;
            cco:targetConfScore 9 ;
            cco:hasTarget ?target  ;
            cco:taxonomy <__TAXON__> 
          ] .
}";

# SPARQL query for split
our %FORCE_SPLIT = ("tax:9606" => 1);
our $QUERY_SPLIT = "PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>
SELECT DISTINCT ?source ?target
FROM <http://rdf.ebi.ac.uk/dataset/chembl>
WHERE {
  ?source a cco:SmallMolecule ;
     cco:hasActivity/cco:hasAssay [
     a cco:Assay ;
     cco:targetConfScore 9 ;
     cco:hasTarget ?target  ;
     cco:taxonomy <__TAXON__>
  ] .
  FILTER (REGEX (STR (?source), '__NUMBER__\$'))
}";
# regex : req. double escape backslash (e.g. '\d' -> '\\d')
our $SOURCE_REGEX = "http://rdf.ebi.ac.uk/resource/chembl/molecule/(.+)";
our $TARGET_REGEX = "http://rdf.ebi.ac.uk/resource/chembl/target/(.+)";
