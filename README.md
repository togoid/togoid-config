# TogoID config

Update procedure and description of link data for TogoID.

![Link diagram](https://github.com/dbcls/togoid-config/blob/main/dot/togoid.png?raw=true)

## Link data

Pair of database IDs in the tab separated value (TSV) format.

```
DB1ID1	DB2IDx
DB1ID2	DB2IDy
DB1ID3	DB2IDz
 :
```

## Config

### Rakefile

Resolve dependencies of update procedure and preparation of common input files for each source DB.

* Prepare: For each config/source-target configuration, prepare common input files for the source database to extract information (if any).
* Prepare: Compare the timestamp of previous donwload and/or file sizes of local and remote files.
* Update: If the timestamp is newer than previously generated link data (TSV), execute the update procedure.
* Update: For the databases which don't have timestamp (e.g., the data source is a SPARQL endpoint), execute the update procedure only when the TSV file is older than given age (e.g., >7 days).
* Convert: If the timestamp of RDF data (TTL) is older than previously generated link data (TSV), execute the convert procedure.

### dataset.yaml

A list of databases (source and target databases kept in the 1st and 2nd columns of the link data file, respectively).

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
go:
  label: Gene ontology
  catalog: nbdc00074
  category: Function
  # Regular expression can be used for automatic detection of the dataset from identifiers given by users.
  # If only a part of the user input should be recognized as an identifier, use a named capture to indicate the part.
  regex: '^(GO[:_])?(?<id>\d{7})$'
  # Identifier format stored in the TSV files (defined by the Handlebars notation with a named capture).
  internal_format: '{{id}}'
  # Identifier format used for export in the TogoID API (defined by the Handlebars notation with a named capture).
  external_format: 'GO:{{id}}'
  prefix: 'http://purl.obolibrary.org/obo/GO_'
  # Example IDs which will be accepted by the TogoID service (thus different types of IDs can be included)
  examples:
    - [ "0046782", "0033644", "0016021", "0033644", "0016021" ]
    - [ "GO:0046782", "GO:0033644", "GO:0016021", "GO:0033644", "GO:0016021" ]
```

### config.yaml

Update procedure of link data and metadata for pair of databases with their relation including definitions of forward/reverse predicates for RDF generation.

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

To update and convert all files:

```
% rake >& `date +%F`.log
```

To update and convert all files in parallel:

```
% rake -m -j 4
```

To update all TSV files:

```sh
% rake update
```

To convert all TSV files into Turtle files:

```sh
% rake convert
```

To update a 'output/tsv/db1-db2.tsv' file:

```sh
% rake output/tsv/db1-db2.tsv
```

To obtain a 'output/ttl/db1-db2.ttl' file:

```sh
% rake output/ttl/db1-db2.ttl
```

#### Rakefile in Docker

Build locally:

```
$ git clone https://github.com/dbcls/togoid-config
$ cd togoid-config
$ docker build -t togoid:test .
$ docker run -it --rm --user $(id -u):$(id -g) -v $(pwd)/input:/togoid/input -v $(pwd)/output:/togoid/output -w /togoid togoid:test rake -m -j 16 update
```

Or by using a container hosted on [GitHub container registry](https://github.com/dbcls/togoid-config/pkgs/container/togoid)

```
$ git clone https://github.com/dbcls/togoid-config
$ cd togoid-config
$ docker run -it --rm --user $(id -u):$(id -g) -v $(pwd)/input:/togoid/input -v $(pwd)/output:/togoid/output -w /togoid ghcr.io/dbcls/togoid:3455a5a rake -m -j 16 update
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

The option `--id` indicates to include identifiers of nodes (database IDs) and predicates of edges.

```sh
% ruby bin/togoid-config-summary config/*/config.yaml | ruby bin/togoid-config-summary-dot --id > togoid.dot
```

Note that rdfs:seeAlso will be highlighted in red to encourage considering more informative predicates.


Also try some other visualization layouts and options:

```sh
% dot -Kcirco -Ppng togoid.dot -otogoid.png
% dot -Kfdp -Ppng togoid.dot -otogoid.png
```

The figure in this repository is generated by the following commands:

```sh
% ruby bin/togoid-config-summary config/*/config.yaml > dot/togoid.sum
% ruby bin/togoid-config-summary-dot --id dot/togoid.sum > dot/togoid.dot
% dot -Nshape=box -Nstyle=filled,rounded -Ecolor=gray -Kdot -Tpng dot/togoid.dot -odot/togoid.png
```
