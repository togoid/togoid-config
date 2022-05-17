# TogoID ver. 1.1

[TogoID](https://togoid.dbcls.jp/) is a service to search and convert links between database identifiers.

Datasets last updated: 2022/05/16


## About

- By entering a list of IDs (up to thousands), candiate links to other databases will be shown. Links can be chained to the target database.

- Users can copy or download the result of conversion as a list of converted IDs, the URLs corresponding to the IDs, and all IDs in the conversion route.

- Links between databases is maintained by the [togoid-config](https://github.com/dbcls/togoid-config) which extracts a pair of identifiers from a SPARQL query for RDF data, database specific APIs, and the flat files of original data sources. See the "DATABASE" tab on the [TogoID](https://togoid.dbcls.jp/) website for a list of supported databases.

## Video tutorial
- [How to use TogoID: Search and convert links between IDs in databases in the life sciences](https://www.youtube.com/watch?v=xxkVEtJMW2k)

## API
- TogoID is also available as an API, which allows other applications to use it for ID conversion.
    1. [https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,ensembl_gene&format=json](https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,ensembl_gene&format=json)
    2. [https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,ensembl_gene,uniprot&format=json](https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,ensembl_gene,uniprot&format=json)
    3. [https://api.togoid.dbcls.jp/convert?format=json&include=pair&route=pubchem_compound,chebi,reactome_reaction,uniprot,ncbigene&ids=649](https://api.togoid.dbcls.jp/convert?format=json&include=pair&route=pubchem_compound,chebi,reactome_reaction,uniprot,ncbigene&ids=649)

- [API Documentation　(Swagger)](https://togoid.dbcls.jp/apidoc/)

## Statistics (as of December 2021)
- Number of target datasets 
    - 64
- Number of dataset pairs
    - 162
- For details on the target DBs and ID examples, please refer to the DATABASES tab. 

## Web user interface

### ID conversion from top page

![Fig-1](https://raw.githubusercontent.com/dbcls/website/master/services/images/TogoID_fig-1_20210707.png)

### Results of ID conversion

![Fig-2](https://raw.githubusercontent.com/dbcls/website/master/services/images/TogoID_fig-2_20210707.png)

### Metadata about the IDs of the listed DBs

![Fig-3](https://raw.githubusercontent.com/dbcls/website/master/services/images/TogoID_fig-3_20210707.png)

