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
  when /#{OUTPUT_TSV_DIR}drugbank/
    return "prepare:drugbank"
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
    $stderr.puts "File #{file} is created #{age} days ago (only updated when >#{days} days)"
    age > days
  else
    true
  end
end

# Generate dependency for preparation by target names
rule /#{OUTPUT_TSV_DIR}\S+\.tsv/ => [ OUTPUT_TSV_DIR, method(:prepare_task) ] do |t|
  pair = t.name.sub(/#{OUTPUT_TSV_DIR}/, '').sub(/\.tsv$/, '')
  #p "Rule1: name = #{t.name} ; source = #{t.source} ; pair = #{pair}"
  $stderr.puts "## Update config/#{pair}/config.yaml => output/tsv/#{pair}.tsv"
  $stderr.puts "< #{`date +%FT%T`.strip} #{pair}"
  if file_older_than_days?(t.name, 1)
    sh "togoid-config config/#{pair} update"
  end
  $stderr.puts "> #{`date +%FT%T`.strip} #{pair}"
end

# Generate source filenames by pathmap notation
rule /#{OUTPUT_TTL_DIR}\S+\.ttl/ => [ OUTPUT_TTL_DIR, "%{#{OUTPUT_TTL_DIR},#{OUTPUT_TSV_DIR}}X.tsv" ] do |t|
  pair = t.name.sub(/#{OUTPUT_TTL_DIR}/, '').sub(/\.ttl$/, '')
  #p "Rule2: name = #{t.name} ; source = #{t.source} ; pair = #{pair}"
  $stderr.puts "## Convert output/tsv/#{pair}.tsv => output/ttl/#{pair}.ttl"
  $stderr.puts "< #{`date +%FT%T`.strip} #{pair}"
  if file_older_than_days?(t.name, 1)
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
    $stderr.puts "Local file size:  #{local_file_size} (#{file})"
    $stderr.puts "Remote file size: #{remote_file_size} (#{url})"
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
    $stderr.puts "Checking lock file #{dir}/download.lock for download"
    File.open("#{dir}/download.lock", "w") do |lockfile|
      if lockfile.flock(File::LOCK_EX)
        lockfile.puts `date +%FT%T`
        lockfile.flush
        yield block
      end
    end
  end

  desc "Prepare required files for Drugbank"
  task :drugbank => INPUT_DRUGBANK_DIR do
    $stderr.puts "TODO: implement prepare:drugbank"
    download_lock(INPUT_DRUGBANK_DIR) do
      # https://go.drugbank.com/releases/5-1-8/downloads/all-full-database
    end
  end

  desc "Prepare taxonomy ID list for Ensembl"
  task :ensembl => INPUT_ENSEMBL_DIR do
    download_lock(INPUT_ENSEMBL_DIR) do
      taxonomy_file = "#{INPUT_ENSEMBL_DIR}/taxonomy.txt"
      if file_older_than_days?(taxonomy_file, 10)
        sh "sparql_csv2tsv.sh #{INPUT_ENSEMBL_DIR}/taxonomy.rq https://integbio.jp/rdf/ebi/sparql > #{taxonomy_file}"
      end
    end
  end

  desc "Prepare required files for HomoloGene"
  task :homologene => INPUT_HOMOLOGENE_DIR do
    download_lock(INPUT_HOMOLOGENE_DIR) do
      input_file = "#{INPUT_HOMOLOGENE_DIR}/homologene.data"
      input_url  = "ftp://ftp.ncbi.nlm.nih.gov/pub/HomoloGene/current/homologene.data"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_HOMOLOGENE_DIR, input_url)
      end
    end
  end

  desc "Prepare required files for InterPro"
  task :interpro => INPUT_INTERPRO_DIR do
    download_lock(INPUT_INTERPRO_DIR) do
      input_file = "#{INPUT_INTERPRO_DIR}/interpro2go"
      input_url  = "ftp://ftp.ebi.ac.uk/pub/databases/interpro/current/interpro2go"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_INTERPRO_DIR, input_url)
      end

      input_file = "#{INPUT_INTERPRO_DIR}/interpro.xml.gz"
      input_url  = "ftp://ftp.ebi.ac.uk/pub/databases/interpro/current/interpro.xml.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_INTERPRO_DIR, input_url)
        sh "gzip -dc #{input_file} | python bin/interpro_xml2tsv.py > #{INPUT_INTERPRO_DIR}/interpro.tsv"
      end
    end
  end

  desc "Prepare required files for NCBI Gene"
  task :ncbigene=> INPUT_NCBIGENE_DIR do
    download_lock(INPUT_NCBIGENE_DIR) do
      input_file = "#{INPUT_NCBIGENE_DIR}/gene2refseq.gz"
      input_url  = "https://ftp.ncbi.nih.gov/gene/DATA/gene2refseq.gz"
      if update_input_file?(input_file, input_url)
        rm_rf input_file
        download_file(INPUT_NCBIGENE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_NCBIGENE_DIR}/gene2refseq"
      end

      input_file = "#{INPUT_NCBIGENE_DIR}/gene2ensembl.gz"
      input_url  = "https://ftp.ncbi.nih.gov/gene/DATA/gene2ensembl.gz"
      if update_input_file?(input_file, input_url)
        rm_rf input_file
        download_file(INPUT_NCBIGENE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_NCBIGENE_DIR}/gene2ensembl"
      end

      input_file = "#{INPUT_NCBIGENE_DIR}/gene2go.gz"
      input_url  = "https://ftp.ncbi.nih.gov/gene/DATA/gene2go.gz"
      if update_input_file?(input_file, input_url)
        rm_rf input_file
        download_file(INPUT_NCBIGENE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_NCBIGENE_DIR}/gene2go"
      end

      input_file = "#{INPUT_NCBIGENE_DIR}/Homo_sapiens.gene_info.gz"
      input_url  = "https://ftp.ncbi.nih.gov/gene/DATA/GENE_INFO/Mammalia/Homo_sapiens.gene_info.gz"
      if update_input_file?(input_file, input_url)
        rm_rf input_file
        download_file(INPUT_NCBIGENE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_NCBIGENE_DIR}/Homo_sapiens.gene_info"
      end
    end
  end

  desc "Prepare required files for RefSeq"
  task :refseq => INPUT_REFSEQ_DIR do
    download_lock(INPUT_REFSEQ_DIR) do
      # Unfortunately, NCBI http/https server won't accept wildcard or --accept option.
      # However, NCBI ftp server is currently broken..
      # (It is reported that large files are contaminated by illegal bytes occationally)
      input_file = "human.*.rna.gbff.gz"
      input_url  = "ftp://ftp.ncbi.nlm.nih.gov:/refseq/H_sapiens/mRNA_Prot/"
      download_file(INPUT_REFSEQ_DIR, input_url, input_file)

      input_file = "#{INPUT_REFSEQ_DIR}/gene_refseq_uniprotkb_collab.gz"
      input_url  = "ftp://ftp.ncbi.nlm.nih.gov/refseq/uniprotkb/gene_refseq_uniprotkb_collab.gz"
      if update_input_file?(input_file, input_url)
        rm_rf input_file
        download_file(INPUT_REFSEQ_DIR, input_url)
      end
    end
  end

  desc "Prepare required files for SRA"
  task :sra => INPUT_SRA_DIR do
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
    download_lock(INPUT_UNIPROT_DIR) do
      input_file = "#{INPUT_UNIPROT_DIR}/idmapping.dat.gz"
      input_url  = "ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping.dat.gz"
      if update_input_file?(input_file, input_url)
        rm_rf input_file
        download_file(INPUT_UNIPROT_DIR, input_url)
        # sh "gzip -dc #{input_file} > #{INPUT_UNIPROT_DIR}/idmapping.dat"
      end
    end
  end
end

task :test do
  p CFG_FILES
  p TSV_FILES
  p TTL_FILES
end

