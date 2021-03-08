# TogoID

directory OUTPUT_TSV_DIR = "output/tsv/"
directory OUTPUT_TTL_DIR = "output/ttl/"

CFG_FILES = FileList["config/*/config.yaml"]
TSV_FILES = CFG_FILES.pathmap("%-1d").sub(/^/, OUTPUT_TSV_DIR).sub(/$/, '.tsv')
TTL_FILES = CFG_FILES.pathmap("%-1d").sub(/^/, OUTPUT_TTL_DIR).sub(/$/, '.ttl')

desc "Default task"
task :default => :convert
desc "Update all TSV files"
task :update  => [ OUTPUT_TSV_DIR, TSV_FILES ]
desc "Update all TTL files"
task :convert => [ OUTPUT_TTL_DIR, TTL_FILES ]

# Some tasks require preparation to extract link data
def prepare_task(taskname)
  case taskname
  when /#{OUTPUT_TSV_DIR}refseq/
    return "prepare:refseq"
  when /#{OUTPUT_TSV_DIR}sra/
    return "prepare:sra"
  when /#{OUTPUT_TSV_DIR}drugbank/
    return "prepare:drugbank"
  when /#{OUTPUT_TSV_DIR}interpro/
    return "prepare:interpro"
  else
    return "config/dataset.yaml"
  end
end

# Generate dependency for preparation by target names
rule /#{OUTPUT_TSV_DIR}.+\.tsv/ => method(:prepare_task) do |t|
  pair = t.name.sub(/#{OUTPUT_TSV_DIR}/, '').sub(/\.tsv$/, '')
  sh "togoid-config config/#{pair} update"
end

# Generate source filenames by pathmap notation
rule /#{OUTPUT_TTL_DIR}.+\.ttl/ => '%{ttl,tsv}X.tsv' do |t|
  pair = t.name.sub(/#{OUTPUT_TTL_DIR}/, '').sub(/\.ttl$/, '')
  sh "togoid-config config/#{pair} convert"
end

# Preparatioin tasks
namespace :prepare do
  directory INPUT_DRUGBANK_DIR = "input/drugbank"
  directory INPUT_INTERPRO_DIR = "input/interpro"
  directory INPUT_REFSEQ_DIR   = "input/refseq"
  directory INPUT_SRA_DIR      = "input/sra"

  # -q -r -np -nd -P (-P needs to take a directory name as an argument)
  WGET_OPTS = "--quiet --recursive --no-parent --no-directories --directory-prefix"

  # The wget --timestamping (-N) option doesn't check the file size.
  # Thus, if newer broken files exist in the input directory, wget won't work.
  def compare_file_size(file, url)
    local_file_size  = File.size(file)
    remote_file_size = `curl -sI #{url} | grep 'Content-Length' | awk '{print $2}'`.strip.to_i
    $stderr.puts "Local file size:  #{local_file_size} (#{file})"
    $stderr.puts "Remote file size: #{remote_file_size} (#{url})"
    return local_file_size != remote_file_size
  end

  # Return true when file sizes differ or file doesn't exist
  def update_input_file(file, url)
    if File.exists?(file)
      compare_file_size(file, url)
    else
      true
    end
  end

  desc "Prepare required files for Drugbank"
  task :drugbank => INPUT_DRUGBANK_DIR do
    $stderr.puts "TODO: implement prepare:drugbank"
    # https://go.drugbank.com/releases/5-1-8/downloads/all-full-database
  end

  desc "Prepare required files for InterPro"
  task :interpro => INPUT_INTERPRO_DIR do
    input_file = "#{INPUT_INTERPRO_DIR}/interpro2go"
    input_url  = "ftp://ftp.ebi.ac.uk/pub/databases/interpro/interpro2go"
    if update_input_file(input_file, input_url)
      sh "wget #{WGET_OPTS} #{INPUT_INTERPRO_DIR} #{input_url}"
    end

    input_file = "#{INPUT_INTERPRO_DIR}/interpro.xml.gz"
    input_url  = "ftp://ftp.ebi.ac.uk/pub/databases/interpro/interpro.xml.gz"
    if update_input_file(input_file, input_url)
      sh "wget #{WGET_OPTS} #{INPUT_INTERPRO_DIR} #{input_url}"
      sh "gzip -dc #{input_file} | python bin/interpro_xml2tsv.py > #{INPUT_INTERPRO_DIR}/interpro.tsv"
    end
  end

  desc "Prepare required files for RefSeq"
  task :refseq => INPUT_REFSEQ_DIR do
    # Unfortunately, NCBI http/https server won't accept wildcard or --accept option.
    # However, NCBI ftp server is currently broken..
    # (It is reported that large files are contaminated by illegal bytes occationally)
    input_file = "human.*.rna.gbff.gz"
    input_url  = "ftp://ftp.ncbi.nlm.nih.gov:/refseq/H_sapiens/mRNA_Prot/"
    sh "wget #{WGET_OPTS} #{INPUT_REFSEQ_DIR} --timestamping --accept '#{input_file}' #{input_url}"
  end

  desc "Prepare required files for SRA"
  task :sra => INPUT_SRA_DIR do
    input_file = "#{INPUT_SRA_DIR}/SRA_Accessions.tab"
    input_url  = "https://ftp.ncbi.nlm.nih.gov/sra/reports/Metadata/SRA_Accessions.tab"
    if update_input_file(input_file, input_url)
      sh "wget #{WGET_OPTS} #{INPUT_SRA_DIR} #{input_url}"
    end
  end
end

task :test do
  p CFG_FILES
  p TSV_FILES
  p TTL_FILES
end

