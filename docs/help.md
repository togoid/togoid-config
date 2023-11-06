# TogoID ver. 1.1
Datasets last updated: 2023-11-06

## About
- [TogoID](https://togoid.dbcls.jp/) is an ID conversion service implementing unique features with an intuitive web interface and an API for programmatic access. TogoID currently supports 89 datasets covering various biological categories. TogoID users can perform exploratory multistep conversions to find a path among IDs. To guide the interpretation of biological meanings in the conversions, we crafted an [ontology](https://togoid.dbcls.jp/ontology) that defines the semantics of the dataset relations.
- The TogoID service is freely available on the [TogoID](https://togoid.dbcls.jp/) website, and the [API](https://togoid.dbcls.jp/apidoc/) is also provided to allow programmatic access.
- To encourage developers to add new dataset pairs, the source code for extracting ID relations is publicly available at [GitHub](https://github.com/dbcls/togoid-config). TogoID performs weekly updates using the programs.
- See the "DATASETS" tab for a list of supported datasets.

## Video tutorial
- [How to use TogoID: an exploratory ID converter to bridge biological datasets](https://youtu.be/gXnvm6Fn4R8)

## Publication

Shuya Ikeda, Hiromasa Ono, Tazro Ohta, Hirokazu Chiba, Yuki Naito, Yuki Moriya, Shuichi Kawashima, Yasunori Yamamoto, Shinobu Okamoto, Susumu Goto, Toshiaki Katayama, TogoID: an exploratory ID converter to bridge biological datasets, _Bioinformatics_, 2022;, btac491, [https://doi.org/10.1093/bioinformatics/btac491](https://doi.org/10.1093/bioinformatics/btac491)

## API
- TogoID is also available as an API, which allows other applications to use it for ID conversion.
    1. [https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,ensembl_gene&format=json](https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,ensembl_gene&format=json)
    2. [https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,ensembl_gene,uniprot&format=json](https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,ensembl_gene,uniprot&format=json)
    3. [https://api.togoid.dbcls.jp/convert?format=json&include=pair&route=pubchem_compound,chebi,reactome_reaction,uniprot,ncbigene&ids=649](https://api.togoid.dbcls.jp/convert?format=json&include=pair&route=pubchem_compound,chebi,reactome_reaction,uniprot,ncbigene&ids=649)

- [API Documentation (Swagger)](https://togoid.dbcls.jp/apidoc/)

## Statistics (as of 2023-11-06)
- Number of target datasets 
    - 102 (from 72 databases)
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
