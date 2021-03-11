# TogoID config

Description of link data for TogoID.

![Link diagram](https://github.com/dbcls/togoid-config/blob/refactoring/dot/togoid.png?raw=true)

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

### dataset.yaml

A list of source and target databases (the 1st and 2nd columns of the link data file, respectively).

```yaml
# Dataset name (in snake_case) for TogoID which can be a subset of original database divided by the category.
ec:
  # Human readable label of the dataset (intended to be used in a Web UI)
  label: Enzyme nomenclature
  # Database identifier provided by the Integbio Database Catalog https://integbio.jp/dbcatalog/
  catalog: nbdc00019
  # Primary category of the database (should be chosen from the tags defined in the Integbio DB Catalog)
  category: Function
  # URI prefix (intended to be used as a URI prefix in RDF)
  prefix: http://identifiers.org/ec-code/
hgnc:
  label: HGNC
  catalog: nbdc01774
  category: Gene
  prefix: http://identifiers.org/hgnc/
pubchem_compound:
  label: PubChem compound
  catalog: nbdc00641
  category: Compound
  prefix: 'https://identifiers.org/pubchem.compound/'
pubchem_substance:
  label: PubChem substance
  catalog: nbdc00642
  category: Compound
  prefix: 'https://identifiers.org/pubchem.substance/'
```

Optional definition of the ID format can be included.

```yaml
# Some datasets have ambiguous identifiers
chebi:
  label: ChEBI compound
  catalog: nbdc00027
  category: Compound
  # Regular expression can be used for automatic detection of the dataset from identifiers given by users.
  # If only a part of the user input should be recognized as an identifier, use a named capture to indicate the part.
  regex: '^(CHEBI:)?(?<id>\d+)$'
  # Identifier format stored in the TSV files (defined by the Handlebars notation with a named capture).
  internal_format: '{{id}}'
  # Identifier format used for export in the TogoID API (defined by the Handlebars notation with a named capture).
  external_format: 'CHEBI:{{id}}'
  prefix: 'https://identifiers.org/chebi/CHEBI:'
go:
  label: Gene ontology
  catalog: nbdc00074
  category: Function
  regex: '^(GO[:_])?(?<id>\d{7})$'
  internal_format: '{{id}}'
  external_format: 'GO:{{id}}'
  prefix: 'http://purl.obolibrary.org/obo/GO_'
```

### config.yaml

Update procedure of link data and definitions of forward/reverse predicates for RDF generation.

```yaml
# Relation of the pair of database identifiers (e.g., hgnc-ec)
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

### Rakefile

To update all TSV files.

```sh
% rake update
```

To convert all TSV files into Turtle files.

```sh
% rake convert
```

To update a 'output/tsv/db1-db2.tsv' file.

```sh
% rake output/tsv/db1-db2.tsv
```

To obtain a 'output/ttl/db1-db2.ttl' file.


```sh
% rake output/ttl/db1-db2.ttl
```

### togoid-config

To check the syntax of the config YAML file:

```sh
% ruby bin/togoid-config config/db1-db2 check
```

To update link data (output/tsv/db1-db2.tsv) from the data source:

```sh
% ruby bin/togoid-config config/db1-db2 update
```

To generate a RDF/Turtle file (output/ttl/db1-db2.ttl) for the given link data:

```sh
% ruby bin/togoid-config config/db1-db2 convert
```

### togoid-config-summary

To summarize all config settings:

```sh
% ruby bin/togoid-config-summary config/*/config.yaml > config-summary.tsv
% vd config-summary.tsv
```

To see the database update frequency:

```sh
% ruby bin/togoid-config-summary config/*/config.yaml | cut -f1,18
```

To see the database update method:

```sh
% ruby bin/togoid-config-summary config/*/config.yaml | cut -f1,19
```

### togoid-config-summary-dot

To visualize config relations:

```sh
% ruby bin/togoid-config-summary config/*/config.yaml | ruby bin/togoid-config-summary-dot > togoid.dot
% dot -Kdot -Ppng togoid.dot -otogoid.png
% open togoid.png
```

The option `--id` indicates to include identifiers of nodes (DBs) and edges (predicates).

```sh
% ruby bin/togoid-config-summary config/*/config.yaml | ruby bin/togoid-config-summary-dot --id > togoid.dot
```

Also try some other visualization layouts and options:

```sh
% dot -Kcirco -Ppng togoid.dot -otogoid.png
% dot -Kfdp -Ppng togoid.dot -otogoid.png
% dot -Nshape=box -Nstyle=filled,rounded -Ecolor=gray -Kdot -Tpng togoid.dot -otogoid.png
```
