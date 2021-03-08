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

# -q -N -r -np -nd -P
WGET_OPTS = "--quiet --timestamping --recursive --no-parent --no-directories --directory-prefix"

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

# The wget --timestamping option should do this job but leave the method just in case.
def compare_size(file, url)
  file_size_old = File.size(file)
  file_size_new = `curl -sI #{url} | grep 'Content-Length' | tr -d '\r' | awk '{print $2}'`
  return file_size_old != file_size_new
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

namespace :prepare do
  directory INPUT_DRUGBANK_DIR = "input/drugbank"
  directory INPUT_INTERPRO_DIR = "input/interpro"
  directory INPUT_REFSEQ_DIR   = "input/refseq"
  directory INPUT_SRA_DIR      = "input/sra"

  task :drugbank => INPUT_DRUGBANK_DIR do
    p "prepare drugbank"
    # https://go.drugbank.com/releases/5-1-8/downloads/all-full-database
  end

  task :interpro => INPUT_INTERPRO_DIR do
    sh "wget #{WGET_OPTS} #{INPUT_INTERPRO_DIR} ftp://ftp.ebi.ac.uk/pub/databases/interpro/interpro2go"
    sh "wget #{WGET_OPTS} #{INPUT_INTERPRO_DIR} ftp://ftp.ebi.ac.uk/pub/databases/interpro/interpro.xml.gz"
    sh "gunzip -f -k #{INPUT_INTERPRO_DIR}/interpro.xml.gz"
  end

  task :refseq => INPUT_REFSEQ_DIR do
    # Unfortunately, NCBI http/https server won't accept wildcard or --accept option.
    # However, NCBI ftp server is currently broken..
    # (It is reported that large files are contaminated by illegal bytes occationally)
    sh "wget #{WGET_OPTS} #{INPUT_REFSEQ_DIR} --accept 'human.*.rna.gbff.gz' ftp://ftp.ncbi.nlm.nih.gov:/refseq/H_sapiens/mRNA_Prot/"
  end

  task :sra => INPUT_SRA_DIR do
    sh "wget #{WGET_OPTS} #{INPUT_SRA_DIR} https://ftp.ncbi.nlm.nih.gov/sra/reports/Metadata/SRA_Accessions.tab"
  end
end

task :test do
  p CFG_FILES
  p TSV_FILES
  p TTL_FILES
end

