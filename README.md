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

* Prepare: For each config/source-target configuration, prepare common input files of the source database under `input/<source>/` by the `prepare:<source>` task (if defined).
  * Compare the timestamp and/or file sizes of remote files with local files previously downloaded, and download only when they are updated.
  * When any file is downloaded, the timestamp of `input/<source>/download.lock` is updated.
* Update: Execute the update procedure (`method` in config.yaml) and generate link data (`output/tsv/db1-db2.tsv`) when one of the following conditions is met:
  * The TSV file does not exist or is empty.
  * The TSV file is older than the config.yaml file.
  * The TSV file is older than `input/<source>/download.lock`.
  * For the databases which don't have `download.lock` (e.g., the data source is a SPARQL endpoint), the TSV file is older than 5 days (`$duration` in the Rakefile).
* Validate: The newly generated TSV file is validated, and the previous TSV file is restored if the validation fails. The TSV file is regarded as invalid when:
  * The file is empty.
  * The file size is less than half of the previous one (`$minratio`).
  * The first and last 10 lines (`$chklines`) contain lines other than "ID tab ID" (e.g., HTML tags, malformed lines, or 2 or more empty lines (`$maxblank`)).
* Convert: Generate RDF data (`output/ttl/relation/db1-db2.ttl`) when the TTL file does not exist, is empty, or is older than the TSV file.
* ID-label: For the datasets which have `method` in dataset.yaml, generate ID-label RDF data (`output/ttl/label/<dataset>.ttl`) when the TTL file does not exist, is empty, or is older than `input/<dataset>/download.lock` (or 5 days old if there is no `download.lock`). The result is validated in the same way as TSV files (file size and syntax check by rapper).

### dataset.yaml

A list of datasets (source and target datasets used in the 1st and 2nd columns of the TSV link data, respectively).

```yaml
# Dataset name (in snake_case) for TogoID which can be a subset of original database divided by the category.
ec:
  # Human readable label of the dataset (intended to be used in a Web UI)
  label: Enzyme nomenclature
  # Database identifier provided by the Integbio Database Catalog https://integbio.jp/dbcatalog/
  # Use an empty string (catalog: "") if there is no corresponding catalog ID for the dataset.
  catalog: nbdc01883
  # Primary category of the database (category must be defined in the TogoID ontology)
  category: Function
  # Regular expression used for automatic detection of the dataset from identifiers given by users.
  # If only a part of the user input should be recognized as an identifier, use a named capture to indicate the part.
  regex: '^(?:EC:)?(?<id>\d+\.(?:(?:-\.-\.-)|\d+\.(?:(?:-\.-)|\d+\.(?:-|n?\d+))))$'
  # List of URI prefixes. Each item has a label and a URI prefix.
  # Exactly one item must have `rdf: true`; its URI is used as the URI prefix in RDF.
  # The other items are used as links to external resources (intended to be used in a Web UI).
  prefix:
    - label: 'identifiers.org'
      uri: 'http://identifiers.org/ec-code/'
      rdf: true
    - label: 'BRENDA'
      uri: 'https://www.brenda-enzymes.org/enzyme.php?ecno='
    - label: 'KEGG'
      uri: 'https://www.genome.jp/dbget-bin/www_bget?ec:'
  # (Optional) ID formats that can be options for output (intended to be used in a Web UI)
  format: ["%s","EC:%s"]
  # Example IDs which are accepted by the TogoID service (thus different types of IDs can be included)
  examples:
    - ["1.6.3.1","2.4.1.353","1.1.1.288","1.5.1.2","3.1.1.71","1.3.1.31","3.5.1.29","1.16.1.1","3.1.3.48","2.3.1.138"]
    - ["EC:1.6.3.1","EC:2.4.1.353","EC:1.1.1.288","EC:1.5.1.2","EC:3.1.1.71","EC:1.3.1.31","EC:3.5.1.29","EC:1.16.1.1","EC:3.1.3.48","EC:2.3.1.138"]
  # (Optional) Command to create an id-label tsv file (converted into output/ttl/label/<dataset>.ttl)
  method: sparql_csv2tsv.sh -w $TOGOID_ROOT/bin/sparql/ec_label.rq https://rdfportal.org/sib/sparql
  # (Optional) Description of the dataset in Markdown (English and Japanese)
  description: "..."
  description_ja: "..."
pubchem_compound:
  label: PubChem compound
  catalog: nbdc00641
  category: Compound
  regex: '^(?:CID)?(?<id>\d+)$'
  prefix:
    - label: 'PubChem'
      uri: 'https://pubchem.ncbi.nlm.nih.gov/compound/'
    - label: 'rdf'
      uri: 'http://rdf.ncbi.nlm.nih.gov/pubchem/compound/CID'
      rdf: true
  format: ["%s","CID%s"]
  examples:
    - ["9548669","160419","9869929","76333303","9868491","27854","76329169","3448","296","10371227"]
    - ["CID9548669","CID160419","CID9869929","CID76333303","CID9868491","CID27854","CID76329169","CID3448","CID296","CID10371227"]
```

Some datasets have additional optional keys used by the TogoID Web application:

```yaml
chebi:
  # (Optional) Settings for converting labels (names, synonyms, etc.) given by users into IDs
  label_resolver:
    threshold: true
    dictionaries:
      - label: Name
        dictionary: togoid_chebi_label
        label_type: label
        preferred: true
      - label: Exact synonym
        dictionary: togoid_chebi_exact_synonym
        label_type: exact_synonym
  # (Optional) Annotations (attributes) of the IDs which can be shown in a Web UI
  annotations:
    - variable: mass
      label: Molecular mass
      # Set true if the values are numerical
      numerical: true
ensembl_transcript:
  annotations:
    - variable: transcript_flag
      label: Transcript flags
      # Possible values of the annotation
      items: ["Ensembl canonical", "MANE Select", "GENCODE Basic"]
      # Set true if an ID can have multiple values
      is_list: true
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
  method: sparql_csv2tsv.sh query.rq https://rdfportal.org/sib/sparql
```

Recommended to use Dublin Core's Frequency Vocabulary [DCFreq](https://www.dublincore.org/specifications/dublin-core/collection-description/frequency/) terms to specify the update frequency.

The `method` is executed in the config directory (e.g., `config/db1-db2/`), and the config directory and `bin/` are added to `PATH`. Thus files placed in the config directory (e.g., `query.rq`) and scripts in `bin/` can be referred to directly. The environment variable `$TOGOID_ROOT` points to the root of this repository (e.g., `$TOGOID_ROOT/input/hgnc/hgnc_complete_set.txt`).

#### Multiple relations in a pair

When a pair of datasets has multiple relations (e.g., different predicates for subsets of the links), describe a list of `link` and `update` in a config.yaml file:

```yaml
- link:
    forward: TIO_000002
    reverse: TIO_000002
    file: sample1.tsv
  update:
    frequency: Monthly
    method: sparql_csv2tsv.sh single_protein.rq https://rdfportal.org/ebi/sparql
- link:
    forward: TIO_000130
    reverse: TIO_000131
    file: sample2.tsv
    # (Optional) Description of the relation
    description: "The ChEMBL Target entries in this relation are of protein families. Each UniProt entry is a member of the families."
  update:
    frequency: Monthly
    method: sparql_csv2tsv.sh protein_family.rq https://rdfportal.org/ebi/sparql
```

In this case, link data of each relation is written to `output/tsv/db1-db2-<forward predicate>.tsv` (e.g., `output/tsv/chembl_target-uniprot-TIO_000130.tsv`), and a copy of the first one is also written to `output/tsv/db1-db2.tsv`. The RDF of all relations is merged into a single `output/ttl/relation/db1-db2.ttl` file.

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

To list available tasks:

```sh
% rake -T
```

To prepare, update and convert all files (the default task runs `prepare:all`, `update`, `convert` and `id_label` in this order):

```
% rake >& `date +%F`.log
```

To update and convert all files in parallel:

```
% rake -m -j 4
```

To prepare input files of all source databases, or of a specific database (e.g., HGNC):

```sh
% rake prepare:all
% rake prepare:hgnc
```

To update all TSV files (input files are also prepared for each source database):

```sh
% rake update
```

To convert all TSV files into Turtle files:

```sh
% rake convert
```

To generate all ID-label Turtle files:

```sh
% rake id_label
```

To update a 'output/tsv/db1-db2.tsv' file:

```sh
% rake output/tsv/db1-db2.tsv
```

To obtain a 'output/ttl/relation/db1-db2.ttl' file:

```sh
% rake output/ttl/relation/db1-db2.ttl
```

To obtain a 'output/ttl/label/dataset.ttl' file:

```sh
% rake output/ttl/label/dataset.ttl
```

#### Upload to AWS S3

The following tasks require the [AWS CLI](https://aws.amazon.com/cli/). The bucket name and the path of the update list can be changed by the environment variables `S3_BUCKET_NAME` (default: `togo-id-production`) and `TOGOID_UPDATE_TXT` (default: `output/tsv/update.txt`).

To show TSV files which differ from those in the S3 bucket:

```sh
% rake aws:show_updated
```

To create the list of updated TSV files (`update.txt`) and upload TSV files and the list to the S3 bucket:

```sh
% rake aws:update
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

To check the syntax of the config YAML file (the parsed config is printed to STDERR; `check` is the default mode and can be omitted):

```sh
% ruby bin/togoid-config config/db1-db2 check
```

To update link data (output/tsv/db1-db2.tsv) from the data source:

```sh
% ruby bin/togoid-config config/db1-db2 update
```

To generate a RDF/Turtle file (output/ttl/relation/db1-db2.ttl) for the given link data:

```sh
% ruby bin/togoid-config config/db1-db2 convert
```

Note that using `togoid-config` directly does not prepare input files nor validate the output; use the Rakefile (e.g., `rake output/tsv/db1-db2.tsv`) for these.

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
