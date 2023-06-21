# Thread limit of SPARQL query
our $THREAD_LIMIT = 10;

# Endpoint
our $EP = "https://integbio.jp/rdf/ebi/sparql";
our $EP_MIRROR = undef;


# SPARQL query for get-target-list
our $QUERY_TAX = "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>

SELECT DISTINCT ?org
FROM <http://rdf.ebi.ac.uk/dataset/chembl>
WHERE {
  ?assay a cco:Assay ;
         cco:assayType ?org .
}";

# SPARQL query for get-ID-list
our $QUERY = "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>

SELECT DISTINCT ?source ?target
FROM <http://rdf.ebi.ac.uk/dataset/chembl>
WHERE {
  ?source a cco:Assay ;
          cco:assayType \"__TAXON__\" ;
          cco:hasActivity / cco:hasMolecule ?target .
}";

# SPARQL query for get-ID-list split by number at the end of taxonomy number
our $QUERY_SPLIT = "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>

SELECT DISTINCT ?source ?target
FROM <http://rdf.ebi.ac.uk/dataset/chembl>
WHERE {
  ?source a cco:Assay ;
          cco:assayType \"__TAXON__\" ;
          cco:chemblId ?id ;
          cco:hasActivity / cco:hasMolecule ?target .
  FILTER(STRENDS(?id, '__NUMBER__'))
}";

# regex : req. double escape backslash (e.g. '\d' -> '\\d')
our $SOURCE_REGEX = "http://rdf.ebi.ac.uk/resource/chembl/assay/(.+)";
our $TARGET_REGEX = "http://rdf.ebi.ac.uk/resource/chembl/molecule/(.+)";


# # SPARQL query for split
# our %FORCE_SPLIT = ("tax:9606" => 1);
# our $QUERY_SPLIT = "PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>
# SELECT DISTINCT ?source ?target
# FROM <http://rdf.ebi.ac.uk/dataset/chembl>
# WHERE {
#   ?source a cco:SmallMolecule ;
#      cco:hasActivity/cco:hasAssay [
#      a cco:Assay ;
#      cco:targetConfScore 9 ;
#      cco:hasTarget ?target  ;
#      cco:taxonomy <__TAXON__>
#   ] .
#   FILTER (REGEX (STR (?source), '__NUMBER__\$'))
# }";
