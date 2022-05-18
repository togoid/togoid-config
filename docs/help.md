# TogoID ver. 1.1
Datasets last updated: 2022/05/16


## About
- [TogoID](https://togoid.dbcls.jp/) is an ID conversion service implementing unique features with an intuitive web interface and an API for programmatic access. TogoID currently supports 65 datasets covering various biological categories. TogoID users can perform exploratory multistep conversions to find a path among IDs.To guide the interpretation of biological meanings in the conversions, we crafted an [ontology](https://togoid.dbcls.jp/ontology) that defines the semantics of the dataset relations.
- The TogoID service is freely available on the [TogoID](https://togoid.dbcls.jp/) website, and the [API](https://togoid.dbcls.jp/apidoc/) is also provided to allow programmatic access. To encourage developers to add new dataset pairs, the source code for extracting ID relations is publicly available at [GitHub](https://github.com/dbcls/togoid-config).
- See the "DATASETS" tab for a list of supported datasets.

## Video tutorial
- [How to use TogoID: Search and convert links between IDs in databases in the life sciences](https://www.youtube.com/watch?v=xxkVEtJMW2k)

## API
- TogoID is also available as an API, which allows other applications to use it for ID conversion.
    1. [https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,ensembl_gene&format=json](https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,ensembl_gene&format=json)
    2. [https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,ensembl_gene,uniprot&format=json](https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,ensembl_gene,uniprot&format=json)
    3. [https://api.togoid.dbcls.jp/convert?format=json&include=pair&route=pubchem_compound,chebi,reactome_reaction,uniprot,ncbigene&ids=649](https://api.togoid.dbcls.jp/convert?format=json&include=pair&route=pubchem_compound,chebi,reactome_reaction,uniprot,ncbigene&ids=649)

- [API Documentation　(Swagger)](https://togoid.dbcls.jp/apidoc/)

## Statistics (as of May 2022)
- Number of target datasets 
    - 65 (from 48 databases)
- For details on the target DBs and ID examples, please refer to the "DATASETS" tab. 

## Web user interface

### ID conversion in the "EXPLORE" mode.

![Fig-1A](https://raw.githubusercontent.com/dbcls/togoid-config/main/docs/img/TogoID_Original_Fig1A.jpg)

### ID conversion in the "NAVIGATE" mode.

![Fig-1B](https://raw.githubusercontent.com/dbcls/togoid-config/main/docs/img/TogoID_Original_Fig1B.jpg)

### Browsing available datasets.

![Fig-2A](https://raw.githubusercontent.com/dbcls/togoid-config/main/docs/img/TogoID_Original_Fig2A.jpg)

### Conversion results.

![Fig-2B](https://raw.githubusercontent.com/dbcls/togoid-config/main/docs/img/TogoID_Original_Fig2B.jpg)

