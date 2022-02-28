#!/bin/sh

#rapper -i turtle -o rdfxml togoid-ontology.ttl > togoid-ontology.rdf
rapper -i turtle -o rdfxml-abbrev togoid-ontology.ttl > togoid-ontology.rdf
xsltproc --output togoid-ontology.html owl2xhtml.xsl togoid-ontology.rdf

