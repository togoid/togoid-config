require "intermine/service"

service = Service.new("https://www.mousemine.org/mousemine/service")
query = service.new_query("Genotype")
query.add_views(
  "primaryIdentifier", "symbol", "zygosity",
  "alleles.primaryIdentifier", "alleles.symbol",
  "ontologyAnnotations.ontologyTerm.identifier"
)

query.each_row do |r|
  puts [r["primaryIdentifier"], r["symbol"], r["zygosity"],
        r["alleles.primaryIdentifier"], r["alleles.symbol"],
        r["ontologyAnnotations.ontologyTerm.identifier"]].join("\t")
end
