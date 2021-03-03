# TogoID config

Description of link data for TogoID.

## Link data

Pair of database IDs in the tab separated value (TSV) format.

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
  # Database identifier in the Integbio Database Catalog https://integbio.jp/dbcatalog/
  catalog: nbdc01774
  # Primary category of the database (should be chosen from the tags defined in the Integbio DB Catalog)
  category: Gene
  # Human readable label of the database (intended to be used in a Web UI)
  label: HGNC
  # URI prefix (intended to be used as a URI prefix in RDF)
  prefix: http://identifiers.org/hgnc/

# Target database (the 2nd column of the link data file)
target:
  catalog: nbdc00019
  category: Reaction
  label: Enzyme Nomenclature
  prefix: http://identifiers.org/ec-code/

# Relation of the pair of database identifiers
link:
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
    label: gene product of
    namespace: ro
    prefix: http://purl.obolibrary.org/obo/
    predicate: RO_0002204

  # Example file name(s) of link data
  file: sample.tsv
#  file:
#    - sample1.tsv
#    - sample2.tsv

# Metadata for updating link data
update:
  # How often the source data is updated
  frequency: Bimonthly
  # Update procedure of link data (can be a script name or a command like)
  method: sparql_csv2tsv.sh query.rq "http://sparql.med2rdf.org/sparql"
```

Recommended to use Dublin Core's Frequency Vocabulary [DCFreq](https://www.dublincore.org/specifications/dublin-core/collection-description/frequency/) terms to specify the update frequency.

## Usage

### config-summary

To summarize all config settings:

```
% ruby bin/config-summary config/*/config.yaml > config-summary.tsv
% vd config-summary.tsv
```

To see the database update frequency:

```
% ruby bin/config-summary config/*/config.yaml | cut -f1,18
```

To see the database update method:

```
% ruby bin/config-summary config/*/config.yaml | cut -f1,19
```

### togoid-config

To check the syntax of the config YAML file:

```
% ruby bin/togoid-config config/db1-db2 check
```

To update link data (output/tsv/db1-db2.tsv) from the data source:

```
% ruby bin/togoid-config config/db1-db2 update
```

To generate a RDF/Turtle file (output/ttl/db1-db2.ttl) for the given link data:

```
% ruby bin/togoid-config config/db1-db2 convert
```

