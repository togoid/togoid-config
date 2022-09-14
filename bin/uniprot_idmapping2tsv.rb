#!/usr/bin/env ruby
#
# Warning:
#   After all, it is not recommended to use this script as the following command line is 3 times faster.
#     % gzip -dc idmapping.dat.gz | grep '\tdb_name\t' | cut -f 1,3"
#   Also, SPARQL endpoint can be far more faster when the number of corresponding ID pairs is very small (depending on the db_name).
#
# Description:
#   Extract cross references for a given DB from the UniProt idmapping.dat file.
#     * ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/README
#     * ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping.dat.gz
#
# Usage:
#   Specify a db_name to extract IDs where the db_name can be one of the databases
#   indicated by the form of `<option ...>db_name</option>` as described below
#   except for DBs which should use alias given in the comment as `Use DB_Name`.
#
#     % uniprot_idmapping2tsv.rb idmapping.dat.gz db_name > uniprot-db_name.tsv
#
# Example:
#     % uniprot_idmapping2tsv.rb idmapping.dat.gz ChEMBL > uniprot-chembl.tsv
#
# Note:
#   According to the README, `idmapping_selected.tab` only contains identifiers
#   only for 22 main databases, however, `idmapping.dat` contains identifiers of
#   99 databases supported by the UniProt ID mapping service.
#     * https://www.uniprot.org/mapping/
#
# idmapping_selected.tab:
#   
#   1. UniProtKB-AC
#   2. UniProtKB-ID
#   3. GeneID (EntrezGene)
#   4. RefSeq
#   5. GI
#   6. PDB
#   7. GO
#   8. UniRef100
#   9. UniRef90
#   10. UniRef50
#   11. UniParc
#   12. PIR
#   13. NCBI-taxon
#   14. MIM
#   15. UniGene
#   16. PubMed
#   17. EMBL
#   18. EMBL-CDS
#   19. Ensembl
#   20. Ensembl_TRS
#   21. Ensembl_PRO
#   22. Additional PubMed
#
# idmapping.dat.gz:
#
#   <optgroup label="UniProt">
#     <option value="ACC">UniProtKB</option>
#     <option value="SWISSPROT">UniProtKB/Swiss-Prot</option>				# Use UniProtKB-ID
#     <option value="UPARC" id="UPARC">UniParc</option>
#     <option value="NF50" id="NF50">UniRef50</option>
#     <option value="NF90" id="NF90">UniRef90</option>
#     <option value="NF100" id="NF100">UniRef100</option>
#     <option value="GENENAME" id="GENENAME">Gene name</option>				# Use Gene_ORFName
#     <option value="CRC64" id="CRC64">CRC64</option>
#   </optgroup>
#   
#   <optgroup label="Sequence" databases="">
#     <option value="EMBL_ID" id="EMBL_ID">EMBL/GenBank/DDBJ</option>			# Use EMBL
#     <option value="EMBL" id="EMBL">EMBL/GenBank/DDBJ CDS</option>			# Use EMBL-CDS
#     <option value="P_ENTREZGENEID" id="P_ENTREZGENEID">Entrez Gene (GeneID)</option>	# Use GeneID
#     <option value="P_GI" id="P_GI">GI number</option>					# Use GI
#     <option value="PIR" id="PIR">PIR</option>
#     <option value="REFSEQ_NT_ID" id="REFSEQ_NT_ID">RefSeq Nucleotide</option>		# Use RefSeq_NT
#     <option value="P_REFSEQ_AC" id="P_REFSEQ_AC">RefSeq Protein</option>		# Use RefSeq
#   </optgroup>
#   
#   <optgroup label="3D" structure="" databases="">
#     <option value="PDB_ID" id="PDB_ID">PDB</option>
#   </optgroup>
#   
#   <optgroup label="Protein-protein" interaction="" databases="">
#     <option value="BIOGRID_ID" id="BIOGRID_ID">BioGRID</option>
#     <option value="COMPLEXPORTAL_ID" id="COMPLEXPORTAL_ID">ComplexPortal</option>
#     <option value="DIP_ID" id="DIP_ID">DIP</option>
#     <option value="STRING_ID" id="STRING_ID">STRING</option>
#   </optgroup>
#   
#   <optgroup label="Chemistry" databases="">
#     <option value="CHEMBL_ID" id="CHEMBL_ID">ChEMBL</option>
#     <option value="DRUGBANK_ID" id="DRUGBANK_ID">DrugBank</option>
#     <option value="GUIDETOPHARMACOLOGY_ID" id="GUIDETOPHARMACOLOGY_ID">GuidetoPHARMACOLOGY</option>
#     <option value="SWISSLIPIDS_ID" id="SWISSLIPIDS_ID">SwissLipids</option>
#   </optgroup>
#   
#   <optgroup label="Protein" family="" group="" databases="">
#     <option value="ALLERGOME_ID" id="ALLERGOME_ID">Allergome</option>
#     <option value="CLAE_ID" id="CLAE_ID">CLAE</option>
#     <option value="ESTHER_ID" id="ESTHER_ID">ESTHER</option>
#     <option value="MEROPS_ID" id="MEROPS_ID">MEROPS</option>
#     <option value="PEROXIBASE_ID" id="PEROXIBASE_ID">PeroxiBase</option>
#     <option value="REBASE_ID" id="REBASE_ID">REBASE</option>
#     <option value="TCDB_ID" id="TCDB_ID">TCDB</option>
#   </optgroup>
#   
#   <optgroup label="PTM" databases="">
#     <option value="GLYCONNECT_ID" id="GLYCONNECT_ID">GlyConnect</option>
#   </optgroup>
#   
#   <optgroup label="Genetic" variation="" databases="">
#     <option value="BIOMUTA_ID" id="BIOMUTA_ID">BioMuta</option>
#     <option value="DMDM_ID" id="DMDM_ID">DMDM</option>
#   </optgroup>
#   
#   <optgroup label="2D" gel="" databases="">
#     <option value="WORLD_2DPAGE_ID" id="WORLD_2DPAGE_ID">World-2DPAGE</option>
#   </optgroup>
#   
#   <optgroup label="Proteomic" databases="">
#     <option value="CPTAC_ID" id="CPTAC_ID">CPTAC</option>
#     <option value="PROTEOMICSDB_ID" id="PROTEOMICSDB_ID">ProteomicsDB</option>
#   </optgroup>
#   
#   <optgroup label="Protocols" and="" materials="" databases="">
#     <option value="DNASU_ID" id="DNASU_ID">DNASU</option>
#   </optgroup>
#   
#   <optgroup label="Genome" annotation="" databases="">
#     <option value="ENSEMBL_ID" id="ENSEMBL_ID">Ensembl</option>			# (ENSG)
#     <option value="ENSEMBL_PRO_ID" id="ENSEMBL_PRO_ID">Ensembl Protein</option>	# Use Ensembl_PRO (ENSP)
#     <option value="ENSEMBL_TRS_ID" id="ENSEMBL_TRS_ID">Ensembl Transcript</option>	# Use Ensembl_TRS (ENST)
#     <option value="ENSEMBLGENOME_ID" id="ENSEMBLGENOME_ID">Ensembl Genomes</option>				# Use EnsemblGenome
#     <option value="ENSEMBLGENOME_PRO_ID" id="ENSEMBLGENOME_PRO_ID">Ensembl Genomes Protein</option>		# Use EnsemblGenome_PRO
#     <option value="ENSEMBLGENOME_TRS_ID" id="ENSEMBLGENOME_TRS_ID">Ensembl Genomes Transcript</option>	# EnsemblGenome_TRS
#     <option value="GENEDB_ID" id="GENEDB_ID">GeneDB</option>
#     <option value="P_ENTREZGENEID" id="P_ENTREZGENEID">GeneID (Entrez Gene)</option>	# Use GeneID
#     <option value="KEGG_ID" id="KEGG_ID">KEGG</option>
#     <option value="PATRIC_ID" id="PATRIC_ID">PATRIC</option>
#     <option value="UCSC_ID" id="UCSC_ID">UCSC</option>
#     <option value="WBPARASITE_ID" id="WBPARASITE_ID">WBParaSite</option>
#   </optgroup>
#   
#   <optgroup label="Organism-specific" databases="">
#     <option value="ARACHNOSERVER_ID" id="ARACHNOSERVER_ID">ArachnoServer</option>
#     <option value="ARAPORT_ID" id="ARAPORT_ID">Araport</option>
#     <option value="CCDS_ID" id="CCDS_ID">CCDS</option>
#     <option value="CGD" id="CGD">CGD</option>
#     <option value="CONOSERVER_ID" id="CONOSERVER_ID">ConoServer</option>
#     <option value="DICTYBASE_ID" id="DICTYBASE_ID">dictyBase</option>
#     <option value="ECHOBASE_ID" id="ECHOBASE_ID">EchoBASE</option>
#     <option value="EUHCVDB_ID" id="EUHCVDB_ID">euHCVdb</option>
#     <option value="FLYBASE_ID" id="FLYBASE_ID">FlyBase</option>
#     <option value="GENECARDS_ID" id="GENECARDS_ID">GeneCards</option>
#     <option value="GENEREVIEWS_ID" id="GENEREVIEWS_ID">GeneReviews</option>
#     <option value="HGNC_ID" id="HGNC_ID">HGNC</option>
#     <option value="LEGIOLIST_ID" id="LEGIOLIST_ID">LegioList</option>
#     <option value="LEPROMA_ID" id="LEPROMA_ID">Leproma</option>
#     <option value="MAIZEGDB_ID" id="MAIZEGDB_ID">MaizeGDB</option>
#     <option value="MGI_ID" id="MGI_ID">MGI</option>
#     <option value="MIM_ID" id="MIM_ID">MIM</option>
#     <option value="NEXTPROT_ID" id="NEXTPROT_ID">neXtProt</option>
#     <option value="ORPHANET_ID" id="ORPHANET_ID">Orphanet</option>
#     <option value="PHARMGKB_ID" id="PHARMGKB_ID">PharmGKB</option>
#     <option value="POMBASE_ID" id="POMBASE_ID">PomBase</option>
#     <option value="PSEUDOCAP_ID" id="PSEUDOCAP_ID">PseudoCAP</option>
#     <option value="RGD_ID" id="RGD_ID">RGD</option>
#     <option value="SGD_ID" id="SGD_ID">SGD</option>
#     <option value="TUBERCULIST_ID" id="TUBERCULIST_ID">TubercuList</option>
#     <option value="VEUPATHDB_ID" id="VEUPATHDB_ID">VEuPathDB</option>
#     <option value="VGNC_ID" id="VGNC_ID">VGNC</option>
#     <option value="WORMBASE_ID" id="WORMBASE_ID">WormBase</option>			# (WBGene)
#     <option value="WORMBASE_PRO_ID" id="WORMBASE_PRO_ID">WormBase Protein</option>	# Use WormBase_PRO
#     <option value="WORMBASE_TRS_ID" id="WORMBASE_TRS_ID">WormBase Transcript</option>	# Use WormBase_TRS
#     <option value="XENBASE_ID" id="XENBASE_ID">Xenbase</option>
#     <option value="ZFIN_ID" id="ZFIN_ID">ZFIN</option>
#   </optgroup>
#   
#   <optgroup label="Phylogenomic" databases="">
#     <option value="EGGNOG_ID" id="EGGNOG_ID">eggNOG</option>
#     <option value="GENETREE_ID" id="GENETREE_ID">GeneTree</option>
#     <option value="HOGENOM_ID" id="HOGENOM_ID">HOGENOM</option>
#     <option value="OMA_ID" id="OMA_ID">OMA</option>
#     <option value="ORTHODB_ID" id="ORTHODB_ID">OrthoDB</option>
#     <option value="TREEFAM_ID" id="TREEFAM_ID">TreeFam</option>
#   </optgroup>
#   
#   <optgroup label="Enzyme" and="" pathway="" databases="">
#     <option value="BIOCYC_ID" id="BIOCYC_ID">BioCyc</option>
#     <option value="PLANT_REACTOME_ID" id="PLANT_REACTOME_ID">PlantReactome</option>
#     <option value="REACTOME_ID" id="REACTOME_ID">Reactome</option>
#     <option value="UNIPATHWAY_ID" id="UNIPATHWAY_ID">UniPathway</option>
#   </optgroup>
#   
#   <optgroup label="Gene" expression="" databases="">
#     <option value="COLLECTF_ID" id="COLLECTF_ID">CollecTF</option>
#   </optgroup>
#   
#   <optgroup label="Family" and="" domain="" databases="">
#     <option value="DISPROT_ID" id="DISPROT_ID">DisProt</option>
#     <option value="IDEAL_ID" id="IDEAL_ID">IDEAL</option>
#   </optgroup>
#   
#   <optgroup label="Miscellaneous" databases="">
#     <option value="CHITARS_ID" id="CHITARS_ID">ChiTaRS</option>
#     <option value="GENEWIKI_ID" id="GENEWIKI_ID">GeneWiki</option>
#     <option value="GENOMERNAI_ID" id="GENOMERNAI_ID">GenomeRNAi</option>
#     <option value="PHI_BASE_ID" id="PHI_BASE_ID">PHI-base</option>
#   </optgroup>
#

require 'zlib'

DATABASES = {
  "UniProt"       => [ "UniProtKB-ID", "UniParc", "UniRef50", "UniRef90", "UniRef100", "Gene_ORFName", "CRC64" ],
  "Sequence"      => [ "EMBL", "EMBL-CDS", "GeneID", "GI", "PIR", "RefSeq_NT", "RefSeq" ],
  "Structure"     => [ "PDB" ],
  "Interaction"   => [ "BioGRID", "ComplexPortal", "DIP", "STRING" ],
  "Chemistry"     => [ "ChEMBL", "DrugBank", "GuidetoPHARMACOLOGY", "SwissLipids" ],
  "Protein"       => [ "Allergome", "CLAE", "ESTHER", "MEROPS", "PeroxiBase", "REBASE", "TCDB" ],
  "Glyco PTM"     => [ "GlyConnect" ],
  "Disease SNV"   => [ "BioMuta", "DMDM" ],
  "2D-PAGE"       => [ "World-2DPAGE" ],
  "Proteomic"     => [ "CPTAC", "ProteomicsDB" ],
  "Protocols"     => [ "DNASU" ],
  "Genome"        => [ "Ensembl", "Ensembl_PRO", "Ensembl_TRS", "EnsemblGenome", "EnsemblGenome_PRO", "EnsemblGenome_TRS", "GeneDB", "GeneID", "KEGG", "PATRIC", "UCSC", "WBParaSite" ],
  "Organism"      => [ "ArachnoServer", "Araport", "CCDS", "CGD", "ConoServer", "dictyBase", "EchoBASE", "euHCVdb", "FlyBase", "GeneCards", "GeneReviews", "HGNC", "LegioList", "Leproma", "MaizeGDB", "MGI", "MIM", "neXtProt", "Orphanet", "PharmGKB", "PomBase", "PseudoCAP", "RGD", "SGD", "TubercuList", "VEuPathDB", "VGNC", "WormBase", "WormBase_PRO", "WormBase_TRS", "Xenbase", "ZFIN" ],
  "Ortholog"      => [ "eggNOG", "GeneTree", "HOGENOM", "OMA", "OrthoDB", "TreeFam" ],
  "Pathway"       => [ "BioCyc", "PlantReactome", "Reactome", "UniPathway" ],
  "TFBS"          => [ "CollecTF" ],
  "Disordered"    => [ "DisProt", "IDEAL" ],
  "Misc"          => [ "ChiTaRS", "GeneWiki", "GenomeRNAi", "PHI-base" ],
}

SUPPORTED_DB = DATABASES.values.flatten

mapping = ARGV.shift
db_name = ARGV.shift

if SUPPORTED_DB.index(db_name)
  query = "\t#{db_name}\t"
else
  $stderr.puts "Error: Database #{db_name} is not supported"
  DATABASES.each do |key, value|
    $stderr.puts "  #{key}:"
    $stderr.puts "    #{value.join(', ')}"
  end
  exit 1
end

# 33:09.00 total for ChEMBL
File.open(mapping) do |input|
  begin
    file = Zlib::GzipReader.new(input)
  rescue Zlib::GzipFile::Error
    file = input
  end

  file.each do |line|
    if line.index(query)
      up, db, id = line.strip.split
      case db
      when /Ensembl/
        id.sub!(/\.\d+$/, '')
      end
      puts "#{up}\t#{id}"
    end
  end
end


=begin
Memo:

# 11:44.57 total for ChEMBL
cmd = "gzip -dc #{mapping} | grep '\t#{db_name}\t' | cut -f 1,3"
IO.popen(cmd) do |io|
  while buffer = io.gets
    puts buffer
  end
end

# 00:24.00 total for ChEMBL with SPARQL
# ## Update config/uniprot-chembl_target/config.yaml => output/tsv/uniprot-chembl_target.tsv
# < 2021-03-20T15:59:52 uniprot-chembl_target
# File output/tsv/uniprot-chembl_target.tsv is created 3.710040506769132 days ago (only updated when >1 days)
# togoid-config config/uniprot-chembl_target update
# > 2021-03-20T16:00:16 uniprot-chembl_target

o uniprot-chembl_target/	P31946  ChEMBL  CHEMBL3710403
x uniprot-dbsnp/
x uniprot-ec/
o uniprot-ensembl_gene/		P31947  Ensembl ENSG00000175793
o uniprot-ensembl_protein/	P31947-1        Ensembl_PRO     ENSP00000340989
o uniprot-ensembl_transcript/	P31947-1        Ensembl_TRS     ENST00000339276
x uniprot-go/                   (use idmapping.tab)
o uniprot-hgnc/			P31947  HGNC    HGNC:10773
x uniprot-intact/
x uniprot-interpro/
o uniprot-ncbigene/		P31947  GeneID  2810
o uniprot-oma_group/		P31947  OMA     GEAECRV
? uniprot-omim_gene/            P31947  MIM     601290
? uniprot-omim_phenotype/
o uniprot-orphanet/		P61981  Orphanet        442835
o uniprot-pdb/			P31947  PDB     1YWT
x uniprot-pfam/
o uniprot-reactome_pathway/	P31947  Reactome        R-HSA-111447
o uniprot-refseq_protein/	O70456  RefSeq  NP_061224.2
=end

