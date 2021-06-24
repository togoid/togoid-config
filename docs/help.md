# TogoID

[TogoID](https://togoid.dbcls.jp/) is a service to search and convert links between database identifiers.

## About

By entering a list of IDs (up to thousands), candiate links to other databases will be shown. Links can be chained to the target database.

Users can copy or download the result of conversion as a list of converted IDs, the URLs corresponding to the IDs, and all IDs in the conversion path.

Extraction of links between databases is maintained by the [togoid-config](https://github.com/dbcls/togoid-config) which executes a SPARQL query for RDF data, database specific APIs, and the flat files of original data sources. See the "DATABASE" tag for a list of supported databases.

## API

* Swagger

## Web user interface

* Copy target IDs

* Download target IDs

* Download target URLs

* Download table as CSV

