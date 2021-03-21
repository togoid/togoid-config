# SPARQL <-> GOA <-> ID mapping comparison

* goa_uniprot_all.gaf.gz  1709661459 pairs (2021-02-17) 30 min to extract
* goa_uniprot_gcrp.gaf.gz  227905893 pairs (2021-02-17)  5 min to extract
* idmapping_selected.tab   371137337 pairs (2021-02-10)  5 min to extract
* uniprot-go.tsv           213223357 pairs (2021-03-03) 54 min to extract

Note that it took 26 min to extract by using
```
% uniprot_goa2tsv.rb goa_uniprot_gcrp.gaf.gz
```
which was much slower than the 5 min command line.
```
% gzip -dc goa_uniprot_gcrp.gaf.gz | grep -v '^!' | cut -f 2,5 | grep 'GO:' | uniq | sed -e 's/GO://'
```

## Performance

| Method   | # Pairs    | Time   | Date       | `sort -u` |
|----------|------------|--------|------------|-----------|
| GOA all  | 1709661459 | 30 min | 2020-02-17 |        NA |
| GOA gcrp |  227905893 |  5 min | 2020-02-17 | 166956860 |
| ID map   |  371137337 |  6 min | 2020-02-10 | 371137337 |
| SPARQL   |  213223357 | 54 min | 2021-03-03 | 213223356 |

* GOA gcrp: [goa_uniprot_gcrp.gaf.gz](ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/UNIPROT/goa_uniprot_gcrp.gaf.gz)
* GOA all:  [goa_uniprot_all.gaf.gz](ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/UNIPROT/goa_uniprot_all.gaf.gz)
* ID map:   [idmapping_selected.tab.gz](ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping.dat.gz)
* SPARQL:   See below

Note that the RDF portal https://integbio.jp/rdf/mirror/ says the UniProt version is 2019-12-19, really?

Also note that the sparql_thread.pl takes a huge RAM and fails often...

```
## Update config/uniprot-go/config.yaml => output/tsv/uniprot-go.tsv
< 2021-03-21T21:42:54 uniprot-go
togoid-config config/uniprot-go update
togoid-config config/uniprot-go update
target:GO_0009881       Fetch error: Endpoint https://integbio.jp/rdf/mirror/uniprot/sparql : 502 Bad Gateway; Endpoint https://sparql.uniprot.org/sparql : 200 OK;
> 2021-03-21T22:55:48 uniprot-go

# 2021-03-21 22:25:06
PID USER      PRI  NI  VIRT   RES   SHR S CPU% MEM%   TIME+  Command
10769 togoid     25   5 49.2G 47.8G  5260 S 36.3 10.9 29:02.24 perl /data/togoid/git/togoid-config.20210321/bin/sparql_thread.pl -t 10

# c.f.
30110 togoid     25   5  243M 63776  3496 R 49.7  0.0 33:30.51 ruby /data/togoid/git/togoid-config.20210321/bin/uniprot_idmapping2tsv.rb
```

Extraction of GO identifiers from ID mapping is bit trickey.

```
% time gzip -dc idmapping_selected.tab.gz | cut -f 1,7 | grep 'GO:' > idm_sel.sh.tsv
50.25s user 20.07s system 18% cpu 6:28.30 total

% time ruby idm_sel.rb idm_sel.sh.tsv > idm_sel.rb.tsv
692.25s user 9.83s system 99% cpu 11:43.77 total

% time wc -l idm_sel.rb.tsv
371137337 idm_sel.rb.tsv
2.36s user 1.50s system 99% cpu 3.871 total

% time sort -u idm_sel.rb.tsv > idm_sel.rb.tsv.su
3065.49s user 114.51s system 438% cpu 12:04.95 total

% time wc -l idm_sel.rb.tsv.su 
371137337 idm_sel.rb.tsv.su
2.29s user 1.56s system 99% cpu 3.862 total
```

## Validation

Tested with P02649 (APOE_HUMAN):

| Method   | APOE lines | `uniq`   | `sort -u`  |
|----------|------------+----------+------------|
| GOA all  |        750 |      546 |        178 |
| GOA gcrp |        348 |      165 |        164 |
| ID map   |          1 |      163 |        163 |
| SPARQL   |         31 |       23 |         23 |

* SPARQL: `sort -u` == DISTINCT

Also confirmed with the official UniProt SPARQL endpoint https://sparql.uniprot.org/ that there are only 23 GO annotations.

### Distinct GOA all = GOA gcrp + 14

```
GO:0051055 BP negative regulation of lipid biosynthetic process
GO:0061000 BP negative regulation of dendritic spine development
GO:0090370 BP negative regulation of cholesterol efflux
GO:1901214 BP regulation of neuron death
GO:1901215 BP negative regulation of neuron death
GO:1901216 BP positive regulation of neuron death
GO:1901627 BP negative regulation of postsynaptic membrane organization
GO:1901631 BP positive regulation of presynaptic membrane organization
GO:1902004 BP positive regulation of amyloid-beta formation
GO:1902947 BP regulation of tau-protein kinase activity
GO:1902951 BP negative regulation of dendritic spine maintenance
GO:1902998 BP positive regulation of neurofibrillary tangle assembly
GO:1902999 BP negative regulation of phospholipid efflux
GO:1903001 BP negative regulation of lipid transport across blood-brain barrier
```

### Distinct GOA all = ID mapping + 15

```
GO:0005515 MF protein binding
GO:0006629 BP lipid metabolic process
GO:0006869 BP lipid transport
GO:0006979 BP response to oxidative stress
GO:0008202 BP steroid metabolic process
GO:0010468 BP regulation of gene expression
GO:0030522 BP intracellular receptor signaling pathway
GO:0042157 BP lipoprotein metabolic process
GO:0042981 BP regulation of apoptotic process
GO:0050807 BP regulation of synapse organization
GO:0055088 BP lipid homeostasis
GO:0072359 BP circulatory system development
GO:0097006 BP regulation of plasma lipoprotein particle levels
GO:0098869 BP cellular oxidant detoxification
GO:0120009 BP intermembrane lipid transfer
```

### Distinct GOA gcrp != ID mapping

* ID mapping only, not found in GOA gcrp (14)

Same as the above 14

```
GO:0051055
GO:0061000
GO:0090370
GO:1901214
GO:1901215
GO:1901216
GO:1901627
GO:1901631
GO:1902004
GO:1902947
GO:1902951
GO:1902998
GO:1902999
GO:1903001
```

* GOA gcrp only, not found in ID mapping (15)

Same as the above 15

```
GO:0005515
GO:0006629
GO:0006869
GO:0006979
GO:0008202
GO:0010468
GO:0030522
GO:0042157
GO:0042981
GO:0050807
GO:0055088
GO:0072359
GO:0097006
GO:0098869
GO:0120009
```

## SPARQL

```sparql
# Endpoint: https://integbio.jp/rdf/uniprot/sparql
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX uniprot: <http://purl.uniprot.org/uniprot/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX db: <http://purl.uniprot.org/database/>

SELECT (count(DISTINCT ?target) AS ?go)
WHERE {
  uniprot:P02649
    a up:Protein ;
    up:classifiedWith ?target .
  ?target
     up:database db:go .
  FILTER (strstarts(str(?target), "http://purl.obolibrary.org/obo/GO_"))
}
```

* All GO identifiers obtained by the SPARQL query (23)

Not that informative?

```
GO:0005102 MF signaling receptor binding
GO:0005794 CC Golgi apparatus
GO:0030425 CC dendrite
GO:0034361 CC very-low-density lipoprotein particle
GO:0034362 CC low-density lipoprotein particle
GO:0034364 CC high-density lipoprotein particle
GO:0005769 CC early endosome
GO:0008203 CC cholesterol metabolic process
GO:0007186 BP G protein-coupled receptor signaling pathway
GO:0008289 MF lipid binding
GO:0005615 CC extracellular space
GO:0005576 CC extracellular region
GO:0005634 CC nucleus
GO:0005783 CC endoplasmic reticulum
GO:0005737 CC cytoplasm
GO:0005886 CC plasma membrane
GO:0016020 CC membrane
GO:0005788 CC endoplasmic reticulum lumen
GO:0008201 MF heparin binding
GO:0043083 CC synaptic cleft
GO:0016209 MF antioxidant activity
GO:0042311 BP vasodilation
GO:0042627 CC chylomicron
```

* Identifiers only in ID mapping, not found in SPARQL (140)

```
GO:0000302 BP response to reactive oxygen species
GO:0001523 BP retinoid metabolic process
GO:0001540 MF amyloid-beta binding
GO:0001937 BP negative regulation of endothelial cell proliferation
GO:0002021 BP response to dietary excess
GO:0005198 MF structural molecule activity
GO:0005319 MF lipid transporter activity
GO:0005543 MF phospholipid binding
GO:0006357 BP regulation of transcription by RNA polymerase II
GO:0006641 BP triglyceride metabolic process
GO:0006707 BP cholesterol catabolic process
GO:0006874 BP cellular calcium ion homeostasis
GO:0006898 BP receptor-mediated endocytosis
GO:0007010 BP cytoskeleton organization
GO:0007263 BP nitric oxide mediated signal transduction
GO:0007271 BP synaptic transmission  cholinergic
GO:0007616 BP long-term memory
GO:0010467 BP gene expression
GO:0010544 BP negative regulation of platelet activation
GO:0010596 BP negative regulation of endothelial cell migration
GO:0010629 BP negative regulation of gene expression
GO:0010873 BP positive regulation of cholesterol esterification
GO:0010875 BP positive regulation of cholesterol efflux
GO:0010877 BP lipid transport involved in lipid storage
GO:0010976 BP positive regulation of neuron projection development
GO:0010977 BP negative regulation of neuron projection development
GO:0015909 BP long-chain fatty acid transport
GO:0017038 BP protein import
GO:0019068 BP virion assembly
GO:0019934 BP cGMP-mediated signaling
GO:0030195 BP negative regulation of blood coagulation
GO:0030516 BP regulation of axon extension
GO:0030669 CC clathrin-coated endocytic vesicle membrane
GO:0031012 CC extracellular matrix
GO:0031175 BP neuron projection development
GO:0032269 BP negative regulation of cellular protein metabolic process
GO:0032489 BP regulation of Cdc42 protein signal transduction
GO:0032805 BP positive regulation of low-density lipoprotein particle receptor catabolic process
GO:0033344 BP cholesterol efflux
GO:0033700 BP phospholipid efflux
GO:0034363 CC intermediate-density lipoprotein particle
GO:0034365 CC discoidal high-density lipoprotein particle
GO:0034371 BP chylomicron remodeling
GO:0034372 BP very-low-density lipoprotein particle remodeling
GO:0034374 BP low-density lipoprotein particle remodeling
GO:0034375 BP high-density lipoprotein particle remodeling
GO:0034378 BP chylomicron assembly
GO:0034380 BP high-density lipoprotein particle assembly
GO:0034382 BP chylomicron remnant clearance
GO:0034384 BP high-density lipoprotein particle clearance
GO:0034447 BP very-low-density lipoprotein particle clearance
GO:0035641 BP locomotory exploration behavior
GO:0042158 BP lipoprotein biosynthetic process
GO:0042159 BP lipoprotein catabolic process
GO:0042632 BP cholesterol homeostasis
GO:0042802 MF identical protein binding
GO:0042803 MF protein homodimerization activity
GO:0042982 BP amyloid precursor protein metabolic process
GO:0043025 CC neuronal cell body
GO:0043254 BP regulation of protein-containing complex assembly
GO:0043395 MF heparan sulfate proteoglycan binding
GO:0043407 BP negative regulation of MAP kinase activity
GO:0043524 BP negative regulation of neuron apoptotic process
GO:0043537 BP negative regulation of blood vessel endothelial cell migration
GO:0043687 BP post-translational protein modification
GO:0043691 BP reverse cholesterol transport
GO:0044267 BP cellular protein metabolic process
GO:0044794 BP positive regulation by host of viral process
GO:0044877 MF protein-containing complex binding
GO:0045088 BP regulation of innate immune response
GO:0045541 BP negative regulation of cholesterol biosynthetic process
GO:0045807 BP positive regulation of endocytosis
GO:0045893 BP positive regulation of transcription  DNA-templated
GO:0046889 BP positive regulation of lipid biosynthetic process
GO:0046907 BP intracellular transport
GO:0046911 MF metal chelating activity
GO:0046983 MF protein dimerization activity
GO:0048156 MF tau protein binding
GO:0048168 BP regulation of neuronal synaptic plasticity
GO:0048844 BP artery morphogenesis
GO:0050709 BP negative regulation of protein secretion
GO:0050728 BP negative regulation of inflammatory response
GO:0050750 MF low-density lipoprotein particle receptor binding
GO:0051000 BP positive regulation of nitric-oxide synthase activity
GO:0051044 BP positive regulation of membrane protein ectodomain proteolysis
GO:0051055 BP negative regulation of lipid biosynthetic process
GO:0051246 BP regulation of protein metabolic process
GO:0051651 BP maintenance of location in cell
GO:0055089 BP fatty acid homeostasis
GO:0060228 MF phosphatidylcholine-sterol O-acyltransferase activator activity
GO:0060999 BP positive regulation of dendritic spine development
GO:0061000 BP negative regulation of dendritic spine development
GO:0061136 BP regulation of proteasomal protein catabolic process
GO:0061771 BP response to caloric restriction
GO:0062023 CC collagen-containing extracellular matrix
GO:0070062 CC extracellular exosome
GO:0070326 MF very-low-density lipoprotein particle receptor binding
GO:0070328 BP triglyceride homeostasis
GO:0070374 BP positive regulation of ERK1 and ERK2 cascade
GO:0071682 CC endocytic vesicle lumen
GO:0071813 MF lipoprotein particle binding
GO:0071830 BP triglyceride-rich lipoprotein particle clearance
GO:0071831 BP intermediate-density lipoprotein particle clearance
GO:0072562 CC blood microparticle
GO:0090090 BP negative regulation of canonical Wnt signaling pathway
GO:0090181 BP regulation of cholesterol metabolic process
GO:0090209 BP negative regulation of triglyceride metabolic process
GO:0090370 BP negative regulation of cholesterol efflux
GO:0097113 BP AMPA glutamate receptor clustering
GO:0097114 BP NMDA glutamate receptor clustering
GO:0098978 CC glutamatergic synapse
GO:0120020 MF cholesterol transfer activity
GO:1900221 BP regulation of amyloid-beta clearance
GO:1900223 BP positive regulation of amyloid-beta clearance
GO:1900272 BP negative regulation of long-term synaptic potentiation
GO:1901214 BP regulation of neuron death
GO:1901215 BP negative regulation of neuron death
GO:1901216 BP positive regulation of neuron death
GO:1901627 BP negative regulation of postsynaptic membrane organization
GO:1901631 BP positive regulation of presynaptic membrane organization
GO:1902004 BP positive regulation of amyloid-beta formation
GO:1902430 BP negative regulation of amyloid-beta formation
GO:1902947 BP regulation of tau-protein kinase activity
GO:1902951 BP negative regulation of dendritic spine maintenance
GO:1902952 BP positive regulation of dendritic spine maintenance
GO:1902991 BP regulation of amyloid precursor protein catabolic process
GO:1902995 BP positive regulation of phospholipid efflux
GO:1902998 BP positive regulation of neurofibrillary tangle assembly
GO:1902999 BP negative regulation of phospholipid efflux
GO:1903001 BP negative regulation of lipid transport across blood-brain barrier
GO:1903002 BP positive regulation of lipid transport across blood-brain barrier
GO:1903561 CC extracellular vesicle
GO:1905855 BP positive regulation of heparan sulfate binding
GO:1905860 BP positive regulation of heparan sulfate proteoglycan binding
GO:1905890 BP regulation of cellular response to very-low-density lipoprotein particle stimulus
GO:1905906 BP regulation of amyloid fibril formation
GO:1905907 BP negative regulation of amyloid fibril formation
GO:1905908 BP positive regulation of amyloid fibril formation
GO:1990777 CC lipoprotein particle
GO:2000822 BP regulation of behavioral fear response
```

### GO annotation

```sh
% go_anotate.rb apoe_go_list.txt
```

```sparql
# Endpoint: https://integbio.jp/rdf/bioportal/sparql
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX GO: <http://purl.obolibrary.org/obo/GO_>
PREFIX oboInOwl: <http://www.geneontology.org/formats/oboInOwl#>

SELECT DISTINCT ?go_id ?ns ?ns_id ?label
FROM <http://integbio.jp/rdf/mirror/bioportal/go>
WHERE {
  GRAPH <http://integbio.jp/rdf/mirror/bioportal/go> {
    VALUES ?go { GO:0005198 GO:0002021 GO:0005783 }
    ?go rdfs:label ?label  ;
        oboInOwl:hasOBONamespace ?ns .
    BIND (IF (contains(?ns, "biological_process"), "BP",
            IF (contains(?ns, "cellular_component"), "CC",
              IF (contains(?ns,	"molecular_function"), "MF", "NA"))) AS ?ns_id)
    BIND (replace(str(?go), go:, 'GO:') AS ?go_id)
  }
}
```

