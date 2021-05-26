# TogoID

ENV['PATH'] = "bin:#{ENV['HOME']}/local/bin:#{ENV['PATH']}"

directory OUTPUT_TSV_DIR = "output/tsv/"
directory OUTPUT_TTL_DIR = "output/ttl/"

CFG_FILES = FileList["config/*/config.yaml"]
TSV_FILES = CFG_FILES.pathmap("%-1d").sub(/^/, OUTPUT_TSV_DIR).sub(/$/, '.tsv')
TTL_FILES = CFG_FILES.pathmap("%-1d").sub(/^/, OUTPUT_TTL_DIR).sub(/$/, '.ttl')

desc "Default task"
task :default => :convert
desc "Update all TSV files"
task :update  => TSV_FILES
desc "Update all TTL files"
task :convert => TTL_FILES

# Some tasks require preparation to extract link data
def prepare_task(taskname)
  case taskname
#  when /#{OUTPUT_TSV_DIR}drugbank/
#    return "prepare:drugbank"
  when /#{OUTPUT_TSV_DIR}ensembl/
    return "prepare:ensembl"
  when /#{OUTPUT_TSV_DIR}homologene/
    return "prepare:homologene"
  when /#{OUTPUT_TSV_DIR}interpro/
    return "prepare:interpro"
  when /#{OUTPUT_TSV_DIR}ncbigene/
    return "prepare:ncbigene"
  when /#{OUTPUT_TSV_DIR}refseq/
    return "prepare:refseq"
  when /#{OUTPUT_TSV_DIR}sra/
    return "prepare:sra"
  when /#{OUTPUT_TSV_DIR}uniprot/
    return "prepare:uniprot"
  else
    return "config/dataset.yaml"
  end
end

# Check if the file is older than 7 (or given) days
def file_older_than_days?(file, days = 7)
  if File.exists?(file)
    age = (Time.now - File.ctime(file)) / (24*60*60)
    $stderr.puts "# File #{file} is created #{age} days ago (only updated when >#{days} days)"
    age > days
  else
    true
  end
end

# Check if the file is older than a given timestamp file
def file_older_than_stamp?(file, stamp)
  if File.exists?(file) && File.exists?(stamp) && File.ctime(file) > File.ctime(stamp)
    $stderr.puts "# File #{file} is newer than #{stamp} (update will be skipped)"
    false
  else
    if File.exists?(stamp)
      $stderr.puts "# File #{file} needs to be created or updated"
      true
    else
      $stderr.puts "# File #{file} has no timestamp file (e.g., depending on SPARQL)"
      file_older_than_days?(file)
    end
  end
end

# Find a timestamp file and compare with the TSV output
def check_tsv_timestamp(pair)
  source = pair.split('-').first
  input  = "input/#{source}/download.lock"
  output = "#{OUTPUT_TSV_DIR}#{pair}.tsv"
  # If there is no timpestamp file (input), update the pair anyway
  file_older_than_stamp?(output, input)
end

# Compare timestamp of the TSV and TTL outputs
def check_ttl_timestamp(pair)
  input  = "#{OUTPUT_TSV_DIR}#{pair}.tsv"
  output = "#{OUTPUT_TTL_DIR}#{pair}.ttl"
  file_older_than_stamp?(output, input)
end

# Generate dependency for preparation by target names
rule /#{OUTPUT_TSV_DIR}\S+\.tsv/ => [ OUTPUT_TSV_DIR, method(:prepare_task) ] do |t|
  pair = t.name.sub(/#{OUTPUT_TSV_DIR}/, '').sub(/\.tsv$/, '')
  #p "Rule1: name = #{t.name} ; source = #{t.source} ; pair = #{pair}"
  $stderr.puts "## Update config/#{pair}/config.yaml => #{OUTPUT_TSV_DIR}#{pair}.tsv"
  $stderr.puts "< #{`date +%FT%T`.strip} #{pair}"
  if check_tsv_timestamp(pair)
    sh "togoid-config config/#{pair} update"
  end
  $stderr.puts "> #{`date +%FT%T`.strip} #{pair}"
end

# Generate source filenames by pathmap notation
rule /#{OUTPUT_TTL_DIR}\S+\.ttl/ => [ OUTPUT_TTL_DIR, "%{#{OUTPUT_TTL_DIR},#{OUTPUT_TSV_DIR}}X.tsv" ] do |t|
  pair = t.name.sub(/#{OUTPUT_TTL_DIR}/, '').sub(/\.ttl$/, '')
  #p "Rule2: name = #{t.name} ; source = #{t.source} ; pair = #{pair}"
  $stderr.puts "## Convert output/tsv/#{pair}.tsv => #{OUTPUT_TTL_DIR}#{pair}.ttl"
  $stderr.puts "< #{`date +%FT%T`.strip} #{pair}"
  if check_ttl_timestamp(pair)
    sh "togoid-config config/#{pair} convert"
  end
  $stderr.puts "> #{`date +%FT%T`.strip} #{pair}"
end

# Preparatioin tasks
namespace :prepare do
  desc "Prepare all"
  task :all => [ :ensembl, :homologene, :interpro, :ncbigene, :refseq, :sra, :uniprot ]

  directory INPUT_DRUGBANK_DIR    = "input/drugbank"
  directory INPUT_ENSEMBL_DIR     = "input/ensembl"
  directory INPUT_HOMOLOGENE_DIR  = "input/homologene"
  directory INPUT_INTERPRO_DIR    = "input/interpro"
  directory INPUT_NCBIGENE_DIR    = "input/ncbigene"
  directory INPUT_REFSEQ_DIR      = "input/refseq"
  directory INPUT_SRA_DIR         = "input/sra"
  directory INPUT_UNIPROT_DIR     = "input/uniprot"

  def download_file(dir, url, glob = nil)
    # -q -r -np -nd -N
    opts = "--quiet --recursive --no-parent --no-directories --timestamping"
    # --directory-prefix (-P) requires a directory name as an argument
    if glob
      sh "wget #{opts} --directory-prefix #{dir} --accept '#{glob}' #{url}"
    else
      sh "wget #{opts} --directory-prefix #{dir} #{url}"
    end
  end

  # The wget --timestamping (-N) option won't check the file size especially when
  # previous download was interrupted and left broken files with newer dates.
  def compare_file_size(file, url)
    local_file_size  = File.size(file)
    remote_file_size = `curl -sI #{url} | grep 'Content-Length' | awk '{print $2}'`.strip.to_i
    $stderr.puts "# Local file size:  #{local_file_size} (#{file})"
    $stderr.puts "# Remote file size: #{remote_file_size} (#{url})"
    return local_file_size != remote_file_size
  end

  # Check if the file sizes differ or the file doesn't exist
  def update_input_file?(file, url)
    if File.exists?(file)
      compare_file_size(file, url)
    else
      true
    end
  end

  # Create file lock to avoid simultaneous access
  def download_lock(dir, &block)
    $stderr.puts "# Checking lock file #{dir}/download.lock for download"
    # File.open with "w" option immediately update the file's timestamp but "a" is fine.
    File.open("#{dir}/download.lock", "a") do |lockfile|
      if lockfile.flock(File::LOCK_EX)
        # Implement block to return true when update procedure is executed (othewise false)
        if yield block
          lockfile.truncate
          lockfile.puts `date +%FT%T`
          lockfile.flush
        end
      end
    end
  end

=begin
  desc "Prepare required files for Drugbank"
  task :drugbank => INPUT_DRUGBANK_DIR do
    $stderr.puts "*** TODO ***: implement prepare:drugbank"
    $stderr.puts "## Prepare input files for Drugbank"
    download_lock(INPUT_DRUGBANK_DIR) do
      updated = false
      # https://go.drugbank.com/releases/5-1-8/downloads/all-full-database
      updated
    end
  end
=end

  desc "Prepare taxonomy ID list for Ensembl"
  task :ensembl => INPUT_ENSEMBL_DIR do
    $stderr.puts "## Prepare input files for Ensembl"
    download_lock(INPUT_ENSEMBL_DIR) do
      updated = false
      taxonomy_file = "#{INPUT_ENSEMBL_DIR}/taxonomy.txt"
      if file_older_than_days?(taxonomy_file, 10)
        sh "sparql_csv2tsv.sh #{INPUT_ENSEMBL_DIR}/taxonomy.rq https://integbio.jp/rdf/ebi/sparql > #{taxonomy_file}"
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for HomoloGene"
  task :homologene => INPUT_HOMOLOGENE_DIR do
    $stderr.puts "## Prepare input files for Homologene"
    download_lock(INPUT_HOMOLOGENE_DIR) do
      updated = false
      input_file = "#{INPUT_HOMOLOGENE_DIR}/homologene.data"
      input_url  = "ftp://ftp.ncbi.nlm.nih.gov/pub/HomoloGene/current/homologene.data"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_HOMOLOGENE_DIR, input_url)
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for InterPro"
  task :interpro => INPUT_INTERPRO_DIR do
    $stderr.puts "## Prepare input files for InterPro"
    download_lock(INPUT_INTERPRO_DIR) do
      updated = false
      input_file = "#{INPUT_INTERPRO_DIR}/interpro2go"
      input_url  = "ftp://ftp.ebi.ac.uk/pub/databases/interpro/current/interpro2go"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_INTERPRO_DIR, input_url)
        updated = true
      end

      input_file = "#{INPUT_INTERPRO_DIR}/protein2ipr.dat.gz"
      input_url  = "ftp://ftp.ebi.ac.uk/pub/databases/interpro/current/protein2ipr.dat.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_INTERPRO_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_INTERPRO_DIR}/protein2ipr.dat"
        updated = true
      end

      input_file = "#{INPUT_INTERPRO_DIR}/interpro.xml.gz"
      input_url  = "ftp://ftp.ebi.ac.uk/pub/databases/interpro/current/interpro.xml.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_INTERPRO_DIR, input_url)
        sh "gzip -dc #{input_file} | python bin/interpro_xml2tsv.py > #{INPUT_INTERPRO_DIR}/interpro.tsv"
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for NCBI Gene"
  task :ncbigene=> INPUT_NCBIGENE_DIR do
    $stderr.puts "## Prepare input files for NCBI Gene"
    download_lock(INPUT_NCBIGENE_DIR) do
      updated = false
      input_file = "#{INPUT_NCBIGENE_DIR}/gene2refseq.gz"
      input_url  = "https://ftp.ncbi.nih.gov/gene/DATA/gene2refseq.gz"
      if update_input_file?(input_file, input_url)
        rm_rf input_file
        download_file(INPUT_NCBIGENE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_NCBIGENE_DIR}/gene2refseq"
        updated = true
      end

      input_file = "#{INPUT_NCBIGENE_DIR}/gene2ensembl.gz"
      input_url  = "https://ftp.ncbi.nih.gov/gene/DATA/gene2ensembl.gz"
      if update_input_file?(input_file, input_url)
        rm_rf input_file
        download_file(INPUT_NCBIGENE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_NCBIGENE_DIR}/gene2ensembl"
        updated = true
      end

      input_file = "#{INPUT_NCBIGENE_DIR}/gene2go.gz"
      input_url  = "https://ftp.ncbi.nih.gov/gene/DATA/gene2go.gz"
      if update_input_file?(input_file, input_url)
        rm_rf input_file
        download_file(INPUT_NCBIGENE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_NCBIGENE_DIR}/gene2go"
        updated = true
      end

      input_file = "#{INPUT_NCBIGENE_DIR}/Homo_sapiens.gene_info.gz"
      input_url  = "https://ftp.ncbi.nih.gov/gene/DATA/GENE_INFO/Mammalia/Homo_sapiens.gene_info.gz"
      if update_input_file?(input_file, input_url)
        rm_rf input_file
        download_file(INPUT_NCBIGENE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_NCBIGENE_DIR}/Homo_sapiens.gene_info"
        updated = true
      end

      input_file = "#{INPUT_NCBIGENE_DIR}/gene_info.gz"
      input_url  = "https://ftp.ncbi.nih.gov/gene/DATA/gene_info.gz"
      if update_input_file?(input_file, input_url)
        rm_rf input_file
        download_file(INPUT_NCBIGENE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_NCBIGENE_DIR}/gene_info"
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for RefSeq"
  task :refseq => INPUT_REFSEQ_DIR do
    $stderr.puts "## Prepare input files for RefSeq"
    download_lock(INPUT_REFSEQ_DIR) do
      updated = false
      input_file = "#{INPUT_REFSEQ_DIR}/RELEASE_NUMBER"
      input_url  = "https://ftp.ncbi.nih.gov/refseq/release/RELEASE_NUMBER"
      if update_input_file?(input_file, input_url)
        # If the RELEASE_NUMBER file is updated, fetch it and then download required data.
        rm_rf input_file
        download_file(INPUT_REFSEQ_DIR, input_url)
        # Unfortunately, NCBI http/https server won't accept wildcard or --accept option.
        # However, NCBI ftp server is currently broken.. You've Been Warned.
        # (It is reported that large files are contaminated by illegal bytes occationally)
        input_file = "complete.*.rna.gbff.gz"
        input_url  = "ftp://ftp.ncbi.nlm.nih.gov:/refseq/release/complete/"
        download_file(INPUT_REFSEQ_DIR, input_url, input_file)
        updated = true
      end

      input_file = "#{INPUT_REFSEQ_DIR}/gene_refseq_uniprotkb_collab.gz"
      input_url  = "ftp://ftp.ncbi.nlm.nih.gov/refseq/uniprotkb/gene_refseq_uniprotkb_collab.gz"
      if update_input_file?(input_file, input_url)
        rm_rf input_file
        download_file(INPUT_REFSEQ_DIR, input_url)
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for SRA"
  task :sra => INPUT_SRA_DIR do
    $stderr.puts "## Prepare input files for SRA"
    download_lock(INPUT_SRA_DIR) do
      input_file = "#{INPUT_SRA_DIR}/SRA_Accessions.tab"
      input_url  = "https://ftp.ncbi.nlm.nih.gov/sra/reports/Metadata/SRA_Accessions.tab"
      if update_input_file?(input_file, input_url)
        rm_rf input_file
        download_file(INPUT_SRA_DIR, input_url)
      end
    end
  end

  desc "Prepare required files for UniProt"
  task :uniprot => INPUT_UNIPROT_DIR do
    $stderr.puts "## Prepare input files for UniProt"
    download_lock(INPUT_UNIPROT_DIR) do
      updated = false
      input_file = "#{INPUT_UNIPROT_DIR}/idmapping.dat.gz"
      #input_url  = "ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping.dat.gz"
      input_url  = "ftp://ftp.ebi.ac.uk/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping.dat.gz"
      if update_input_file?(input_file, input_url)
        rm_rf input_file
        download_file(INPUT_UNIPROT_DIR, input_url)
        updated = true
      end
      input_file = "#{INPUT_UNIPROT_DIR}/idmapping_selected.tab.gz"
      input_url  = "ftp://ftp.ebi.ac.uk/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping_selected.tab.gz"
      if update_input_file?(input_file, input_url)
        rm_rf input_file
        download_file(INPUT_UNIPROT_DIR, input_url)
        sh "gzip -dc #{INPUT_UNIPROT_DIR}/idmapping_selected.tab.gz | cut -f 1,7 | grep 'GO:' > #{INPUT_UNIPROT_DIR}/idmapping_selected.go"
        updated = true
      end
      # Not used:
      #input_url  = "ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/UNIPROT/goa_uniprot_all.gaf.gz"
      updated
    end
  end
end

task :test do
  p CFG_FILES
  p TSV_FILES
  p TTL_FILES
end

