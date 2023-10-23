from intermine.webservice import Service

service = Service("https://www.mousemine.org/mousemine/service")
query = service.new_query("Genotype")
query.add_view(
    "primaryIdentifier", "symbol", "zygosity",
    "alleles.primaryIdentifier", "alleles.symbol",
    "ontologyAnnotations.ontologyTerm.identifier"
)

for row in query.rows():
    print(row["primaryIdentifier"], row["symbol"], row["zygosity"],
          row["alleles.primaryIdentifier"], row["alleles.symbol"],
          row["ontologyAnnotations.ontologyTerm.identifier"],
          sep="\t")
