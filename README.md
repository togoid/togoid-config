# TogoID config

Description of link data for TogoID.

## Link data

Pair of database IDs in the tab separated value (TSV) format.
The name of this file should be listed in the following config file.

```
DB1ID1	DB2IDx
DB1ID2	DB2IDy
DB1ID3	DB2IDz
 :
```

## Config

Metadata for pair of databases and their relation.

```
# Source database (the 1st column of the link data file)
source:
  # Human readable label (intended to be used in a Web UI)
  label: KEGG Orthology
  # Category (should be a class defined in the TogoID ontology; TBD)
  type: Ortholog
  # Unique short name (intended to be used as a name space in RDF)
  name: ko
  # URI prefix (intended to be used as a prefix in RDF)
  prefix: http://identifiers.org/kegg.orthology/

# Target database (the 2nd column of the link data file)
target:
  label: Gene Ontology
  type: Function
  name: go
  prefix: http://purl.obolibrary.org/obo/

# Relation of the pair of database identifiers
link:
  label: Functionally related to
  name: ro
  # Ontology URI which defines predicates
  prefix: http://purl.obolibrary.org/obo/
  # Selected predicate defined in the above ontology
  predicate: RO_0002328
  # If set to true, reverse link will also be generated
#  directed: true
  directed: false
  # File name(s) of link data
  file: link.tsv
#  file:
#    - link.1.tsv
#    - link.2.tsv

# Metadata for updating link data
update:
  # How often the source data is updated
  frequency: Monthly
  # Update procedure of link data (can be a script name etc.)
  method: curl http://rest.genome.jp/link/go/ko | perl -pe 's/ko://; s/go:/GO_/' > link.tsv
```

## Usage

To generate a RDF/Turtle file for the given link data, run the following command.

```
% ruby bin/togoid-config.rb link/ko-go/config.yaml > ko-go.ttl
% ruby bin/togoid-config.rb link/uniprot-hgnc/config.yaml > uniprot-hgnc.ttl
```

