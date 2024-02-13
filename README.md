# TogoID config

Update procedure and description of link data for TogoID.

![Link diagram](https://github.com/dbcls/togoid-config/blob/main/docs/dot/togoid.png?raw=true)

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

* Prepare: For each config/source-target configuration, prepare common input files of the source database to extract information (if any).
* Prepare: Compare the timestamp and/or file sizes of remote files with local files previously downloaded.
* Update: If the timestamp is newer than previously generated link data (TSV), execute the update procedure.
* Update: For the databases which don't have timestamp (e.g., the data source is a SPARQL endpoint), execute the update procedure only when the TSV file is older than given age (e.g., >7 days).
* Convert: If the timestamp of RDF data (TTL) is older than previously generated link data (TSV), execute the convert procedure.

### dataset.yaml

A list of datasets (source and target datasets used in the 1st and 2nd columns of the TSV link data, respectively).

```yaml
# Dataset name (in snake_case) for TogoID which can be a subset of original database divided by the category.
ec:
  # Human readable label of the dataset (intended to be used in a Web UI)
  label: Enzyme nomenclature
  # Database identifier provided by the Integbio Database Catalog https://integbio.jp/dbcatalog/
  catalog: nbdc01883
  # Primary category of the database (category must be defined in the TogoID ontology)
  category: Function
  # Regular expression used for automatic detection of the dataset from identifiers given by users.
  # If only a part of the user input should be recognized as an identifier, use a named capture to indicate the part.
  regex: '^(?:EC:)?(?<id>\d+\.(?:(?:-\.-\.-)|\d+\.(?:(?:-\.-)|\d+\.(?:-|n?\d+))))$'
  # URI prefix (intended to be used as a URI prefix in RDF)
  prefix: http://identifiers.org/ec-code/
  # (Optional) ID format that can be options for output (intended to be used in a Web UI)
  format: ["EC:%s"]
  # Example IDs which are accepted by the TogoID service (thus different types of IDs can be included)
  examples:
    - ["1.6.3.1","2.4.1.353","1.1.1.288","1.5.1.2","3.1.1.71","1.3.1.31","3.5.1.29","1.16.1.1","3.1.3.48","2.3.1.138"]
    - ["EC:1.6.3.1","EC:2.4.1.353","EC:1.1.1.288","EC:1.5.1.2","EC:3.1.1.71","EC:1.3.1.31","EC:3.5.1.29","EC:1.16.1.1","EC:3.1.3.48","EC:2.3.1.138"]
  # (Optional) Command to create an id-label tsv file
  method: sparql_csv2tsv.sh -w $TOGOID_ROOT/bin/sparql/ec_label.rq https://rdfportal.org/sib/sparql
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

### config.yaml

Update procedure of link data and metadata for pair of datasets with their relation including definitions of forward/reverse predicates for RDF generation.

```yaml
# Relation of the pair of database identifiers (e.g., hgnc-ec)
link:
  # Forward link (source to target), predicate must be defined in the TogoID ontology
  forward: TIO_000028
  # Reverse link (target to source)
  reverse: TIO_000029
  # Example file name(s) of link data (only for testing)
  file: sample.tsv

# Metadata for updating link data
update:
  # How often the source data is updated
  frequency: Bimonthly
  # Update procedure of link data (can be a script name or a command line)
  method: sparql_csv2tsv.sh query.rq "http://sparql.med2rdf.org/sparql"
```

Recommended to use Dublin Core's Frequency Vocabulary [DCFreq](https://www.dublincore.org/specifications/dublin-core/collection-description/frequency/) terms to specify the update frequency.

## Ontology

Dependencies:
* rapper command in [raptor](https://librdf.org/raptor/)
* xsltproc command in [libxml](http://www.xmlsoft.org/)

TogoID ontology ([TIO](http://togoid.dbcls.jp/ontology/)) is introduced to semantically describe the datasets and the relations between datasets in TogoID.

## Usage

### Rakefile

Dependencies:
* [ruby](https://www.ruby-lang.org/) and rake (default bundle in ruby)
* [docker](https://www.docker.com/) described below or install all dependent UNIX commands used in the config.yaml files

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

To test the syntax of the config YAML file:

```sh
% ruby bin/togoid-config config/db1-db2 test
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
% ruby bin/togoid-config-summary config/*/config.yaml | cut -f1,16
```

To see the database update method:

```sh
% ruby bin/togoid-config-summary config/*/config.yaml | cut -f1,17
```

### togoid-config-summary-dot

Dependencies:
* dot command in [graphviz](https://graphviz.org/)

To visualize config relations:

```sh
% ruby bin/togoid-config-summary config/*/config.yaml | ruby bin/togoid-config-summary-dot > togoid.dot
% dot -Kdot -Ppng togoid.dot -otogoid.png
% open togoid.png
```

The option `--id` indicates to include identifiers of nodes (dataset IDs) and predicates of edges.

```sh
% ruby bin/togoid-config-summary config/*/config.yaml | ruby bin/togoid-config-summary-dot --id > togoid.dot
```

Also try some other visualization layouts and options:

```sh
% dot -Kcirco -Ppng togoid.dot -otogoid.png
% dot -Kfdp -Ppng togoid.dot -otogoid.png
```

The figure in this repository is generated by the following commands:

```sh
% ruby bin/togoid-config-summary config/*/config.yaml > docs/dot/togoid.sum
% ruby bin/togoid-config-summary-dot --id docs/dot/togoid.sum > docs/dot/togoid.dot
% dot -Nshape=box -Nstyle=filled,rounded -Ecolor=gray -Kdot -Tpng docs/dot/togoid.dot -odocs/dot/togoid.png
```
