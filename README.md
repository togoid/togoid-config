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

```yaml
# Source database (the 1st column of the link data file)
source:
  # Human readable label (intended to be used in a Web UI)
  label: KEGG Orthology
  # Category (should be a class defined in the TogoID ontology; TBD)
  type: Ortholog
  # Unique short name (intended to be used as a name space in RDF)
  # Recommended to use the prefix name defined at prefixcommons.org
  namespace: kegg.orthology
  # URI prefix (intended to be used as a prefix in RDF)
  prefix: http://identifiers.org/kegg.orthology/

# Target database (the 2nd column of the link data file)
target:
  label: Gene Ontology
  type: Function
  namespace: go
  prefix: http://purl.obolibrary.org/obo/

# Relation of the pair of database identifiers
link:
  # File name(s) of link data
  file: link.tsv
#  file:
#    - link.1.tsv
#    - link.2.tsv

  # Forward link (source to target)
  forward:
    label: functionally related to
    namespace: ro
    # Ontology URI which defines predicates
    prefix: http://purl.obolibrary.org/obo/
    # Selected predicate defined in the above ontology
    predicate: RO_0002328

  # Reverse link (optional; target to source)
  reverse:
    label: enabled by
    namespace: ro
    prefix: http://purl.obolibrary.org/obo/
    predicate: RO_0002333

# Metadata for updating link data
update:
  # How often the source data is updated
  frequency: Monthly
  # Update procedure of link data (can be a script name or a command like)
  method: curl http://rest.genome.jp/link/go/ko | cut -f 1,2 | perl -pe 's/ko://; s/go:/GO_/' > link.tsv
```

Recommended to use Dublin Core™ Collection Description Frequency Vocabulary [DCFreq](https://www.dublincore.org/specifications/dublin-core/collection-description/frequency/) terms to specify the update frequency.

## Usage

To update link data from the data source, run the following command.

```
% ruby bin/togoid-config.rb link/uniprot-hgnc/config.yaml update
```

To generate a RDF/Turtle file for the given link data, run the following command.

```
% ruby bin/togoid-config.rb link/uniprot-hgnc/config.yaml convert > uniprot-hgnc.ttl
```

