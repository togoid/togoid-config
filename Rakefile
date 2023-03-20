# TogoID

require 'time'

ENV['PATH'] = "bin:#{ENV['HOME']}/local/bin:#{ENV['PATH']}"

### Options

$verbose = true  # Flag to enable verbose output for STDERR

# TogoID#file_older_than_days?()
$duration = 7    # Default number of days to force update

# TogoID#validate_tsv_output()
$chklines = 10   # Number of head and tail lines to be validated
$maxblank = 2    # Maximum number of acceptable empty lines in TSV files
$minratio = 0.5  # Minimum acceptable size ratio of new / old TSV file sizes

### Tasks

directory OUTPUT_TSV_DIR = "output/tsv/"
directory OUTPUT_TTL_DIR = "output/ttl/"

CFG_FILES = FileList["config/*/config.yaml"]
TSV_FILES = CFG_FILES.pathmap("%-1d").sub(/^/, OUTPUT_TSV_DIR).sub(/$/, '.tsv')
TTL_FILES = CFG_FILES.pathmap("%-1d").sub(/^/, OUTPUT_TTL_DIR).sub(/$/, '.ttl')

# For update procedure on AWS
UPDATE_TXT     = File.join(OUTPUT_TSV_DIR, "update.txt")
S3_BUCKET_NAME = ENV['S3_BUCKET_NAME']

desc "Default task (update & convert)"
#task :default => [ :pre, :update, :convert, :post ]
task :default => [ :pre, 'prepare:all', :update, :convert, :post ]
desc "Update all TSV files"
task :update  => TSV_FILES
desc "Update all TTL files"
task :convert => TTL_FILES

desc "Pre task"
task :pre do
  $stderr.puts "*** Started: #{`date +%FT%T`.strip} ***"
  $stderr.puts
end

desc "Post task"
task :post do
  $stderr.puts
  $stderr.puts "*** Finished: #{`date +%FT%T`.strip} ***"
end

desc "Show targets"
task :test do
  p CFG_FILES
  p TSV_FILES
  p TTL_FILES
end

desc "Draw a diagram with graphviz"
task :draw do
  sh "togoid-config-summary config/*/config.yaml > docs/dot/togoid.sum"
  sh "togoid-config-summary-dot --id dot/togoid.sum > docs/dot/togoid.dot"
  sh "dot -Nshape=box -Nstyle=filled,rounded -Nfontcolor=white -Ecolor=gray -Kdot -Tpng docs/dot/togoid.dot -odocs/dot/togoid.png"
end

### Methods

module TogoID
  # Methods for update/convert
  module Main
    # Entry point for TSV update
    def update_tsv(taskname)
      if taskname[/#{OUTPUT_TSV_DIR}/]
        pair = taskname.sub(/#{OUTPUT_TSV_DIR}/, '').sub(/\.tsv$/, '')
        if $verbose
          $verbose = false
          $stderr.puts "### Update TSV for #{pair} if check_tsv_filesize #{check_tsv_filesize(pair)} or check_config_timestamp #{check_config_timestamp(pair)} or check_tsv_timestamp #{check_tsv_timestamp(pair)}"
          $verbose = true
        end
        if check_tsv_filesize(pair) or check_config_timestamp(pair) or check_tsv_timestamp(pair)
          $stderr.puts "## Update #{config_file_name(pair)} => #{tsv_file_name(pair)}"
          $stderr.puts "< #{`date +%FT%T`.strip} #{pair}"
          if File.exists?(tsv_file_name(pair))
            # Backup previous TSV output
            sh "mv #{tsv_file_name(pair)} #{tsv_file_name_old(pair)}", verbose: false
          end
          sh "togoid-config #{config_dir_name(pair)} update"
          if validate_tsv_output(pair)
            $stderr.puts "# Success: #{tsv_file_name(pair)} is updated"
            if File.exists?(tsv_file_name_old(pair))
              # Remove prevous TSV output
              sh "rm #{tsv_file_name_old(pair)}", verbose: false
            end
          else
            $stderr.puts "# Failure: #{tsv_file_name(pair)} is not updated"
            if File.exists?(tsv_file_name_old(pair))
              # Revert previous TSV output"
              sh "mv #{tsv_file_name_old(pair)} #{tsv_file_name(pair)}", verbose: false
            end
          end
          $stderr.puts "> #{`date +%FT%T`.strip} #{pair}"
        else
          $stderr.puts "# => Preserving #{tsv_file_name(pair)}"
        end
      end
      return "config/dataset.yaml"
    end

    # Entry point for TTL convert
    def update_ttl(taskname)
      if taskname[/#{OUTPUT_TTL_DIR}/]
        pair = taskname.sub(/#{OUTPUT_TTL_DIR}/, '').sub(/\.ttl$/, '')
        if $verbose
          $verbose = false
          $stderr.puts "### Update TTL for #{pair} if check_ttl_filesize #{check_ttl_filesize(pair)} or check_ttl_timestamp #{check_ttl_timestamp(pair)}"
          $verbose = true
        end
        if check_ttl_filesize(pair) or check_ttl_timestamp(pair)
          $stderr.puts "## Convert #{tsv_file_name(pair)} => #{ttl_file_name(pair)}"
          $stderr.puts "< #{`date +%FT%T`.strip} #{pair}"
          sh "togoid-config #{config_dir_name(pair)} convert"
          $stderr.puts "> #{`date +%FT%T`.strip} #{pair}"
        else
          $stderr.puts "# => Preserving #{ttl_file_name(pair)}"
        end
      end
      return "config/dataset.yaml"
    end

    def config_dir_name(pair)
      "config/#{pair}"
    end

    def config_file_name(pair)
      "config/#{pair}/config.yaml"
    end

    def tsv_file_name(pair)
      "#{OUTPUT_TSV_DIR}#{pair}.tsv"
    end

    def tsv_file_name_old(pair)
      "#{OUTPUT_TSV_DIR}#{pair}.tsv.old"
    end

    def ttl_file_name(pair)
      "#{OUTPUT_TTL_DIR}#{pair}.ttl"
    end

    # Return true (needs update) when the TSV file does not exist or the size is zero
    def check_tsv_filesize(pair)
      output = tsv_file_name(pair)
      return ! (File.exists?(output) and File.size(output) > 0)
    end

    # Return true (needs update) when the TTL file does not exist or the size is zero
    def check_ttl_filesize(pair)
      output = ttl_file_name(pair)
      return ! (File.exists?(output) and File.size(output) > 0)
    end

    # Return true (needs udpate) when the TSV file is older than the config file
    def check_config_timestamp(pair)
      input = config_file_name(pair)
      output = tsv_file_name(pair)
      file_older_than_stamp?(output, input)
    end

    # Return true (needs update) when the TSV file is older than the timestamp file
    def check_tsv_timestamp(pair)
      source = pair.split('-').first
      input  = "input/#{source}/download.lock"
      output = tsv_file_name(pair)
      # If there is no timpestamp file (input), update the pair anyway
      file_older_than_stamp?(output, input)
    end

    # Return true (needs update) when the TTL file is older than the TSV file
    def check_ttl_timestamp(pair)
      input  = tsv_file_name(pair)
      output = ttl_file_name(pair)
      file_older_than_stamp?(output, input)
    end

    # Return true (needs update) unless the output file exists and newer than the given timestamp file (if available)
    def file_older_than_stamp?(file, stamp)
      if File.exists?(file) && File.exists?(stamp) && File.mtime(file) > File.mtime(stamp)
        $stderr.puts "# File #{file} is newer than #{stamp}" if $verbose
        false
      else
        if File.exists?(stamp)
          $stderr.puts "# File #{file} is older than #{stamp}" if $verbose
          true
        else
          $stderr.puts "# File #{file} has no timestamp file" if $verbose
          file_older_than_days?(file)
        end
      end
    end

    # Return true (needs update) when the file is older than $duration (or given) days
    def file_older_than_days?(file, days = $duration)
      if File.exists?(file)
        age = (Time.now - File.mtime(file)) / (24*60*60)
        $stderr.puts "# File #{file} is created #{age} days ago (will be updated when >#{days} days)" if $verbose
        age > days
      else
        true
      end
    end

    def validate_tsv_output(pair)
      tsv = tsv_file_name(pair)
      old = tsv_file_name_old(pair)
      check = true
      count = 0
      if File.exists?(tsv) and File.exists?(old)
        ratio = 1.0 * File.size(tsv) / File.size(old)
        # New file is not smaller than a half of old file size
        if ratio < $minratio
          $stderr.puts "# Error: #{tsv} new file size per old #{File.size(tsv)} / #{File.size(old)} = #{ratio} < #{$minratio}" if $verbose
          check = false
        end
      end
      # Check if new TSV is valid (regardless of the previous TSV output exists or not)
      if File.exists?(tsv) and File.size(tsv) > 0
        head = `head -#{$chklines} #{tsv}`
        tail = `tail -#{$chklines} #{tsv}`
        [head, tail].each do |lines|
          lines.each_line do |line|
            line.strip!
            if line[/^\S+\t\S+$/]	# check ID tab ID
              #$stderr.puts "# Pass: #{tsv} seems to be OK #{line}" if $verbose
              # Do nothing
            elsif line[/</]		# check HTML tag
              $stderr.puts "# Error: #{tsv} seems to contain HTML #{line}" if $verbose
              check = false
            elsif line.size == 0	# check empty line
              count += 1
              if count >= $maxblank
                $stderr.puts "# Error: #{tsv} seems to contain >#{count} empty lines" if $verbose
                check = false
              end
            else
              $stderr.puts "# Error: #{tsv} seems to be malformed #{line}" if $verbose
              check = false
            end
          end
        end
      else
        $stderr.puts "# Error: Failed to create #{tsv} or created file was empty" if $verbose
        check = false
      end
      return check
    end
  end

  # Methods for preparation
  module Prepare
    # Entry point for preparation
    def prepare_task(taskname)
      case taskname
#      when /#{OUTPUT_TSV_DIR}drugbank/
#        return "prepare:drugbank"
      when /#{OUTPUT_TSV_DIR}cellosaurus/
        return "prepare:cellosaurus"
      when /#{OUTPUT_TSV_DIR}ensembl/
        return "prepare:ensembl"
      when /#{OUTPUT_TSV_DIR}homologene/
        return "prepare:homologene"
      when /#{OUTPUT_TSV_DIR}cog/
        return "prepare:cog"
      when /#{OUTPUT_TSV_DIR}interpro/
        return "prepare:interpro"
      when /#{OUTPUT_TSV_DIR}ncbigene/
        return "prepare:ncbigene"
      when /#{OUTPUT_TSV_DIR}reactome/
        return "prepare:reactome"
      when /#{OUTPUT_TSV_DIR}refseq/
        return "prepare:refseq"
      when /#{OUTPUT_TSV_DIR}rhea/
        return "prepare:rhea"
      when /#{OUTPUT_TSV_DIR}sra/
        return "prepare:sra"
      when /#{OUTPUT_TSV_DIR}swisslipids/
        return "prepare:swisslipids"
      when /#{OUTPUT_TSV_DIR}uniprot/
        return "prepare:uniprot"
      when /#{OUTPUT_TSV_DIR}taxonomy/
        return "prepare:taxonomy"
      else
        return "config/dataset.yaml"
      end
    end

    # Check if the file is updated or the sizes differ or the file doesn't exist
    def update_input_file?(file, url)
      if File.exists?(file)
        # Both checks should be made as the local file can be newer than remote when the previous download fails
        check_remote_file_time(file, url)
        # and the local file can be smaller or size 0 even when it exists
        check_remote_file_size(file, url)
      else
        true
      end
    end

    # Create file lock to avoid simultaneous access
    def download_lock(dir, &block)
      $stderr.puts "# Checking lock file #{dir}/download.lock for download"
      # File.open with "w" option immediately update the file's timestamp but "a" preserve the timestamp when not modified
      File.open("#{dir}/download.lock", "a") do |lockfile|
        if lockfile.flock(File::LOCK_EX)
          # Each downloader needs to implement a block returning true when update procedure is executed (othewise false)
          if yield block
            $stderr.puts "# Overwriting timestamp of the #{dir}/download.lock"
            lockfile.truncate(0)
            lockfile.puts `date +%FT%T`
            lockfile.flush
          else
            $stderr.puts "# Preserving timestamp of the #{dir}/download.lock"
          end
        end
      end
    end

    # Download files with wget
    def download_file(dir, url, glob = nil)
      # When running Wget without -N, -nc, -r, or -p, downloading the same file in the same directory
      # will result in the original copy of file being preserved and the second copy being named file.1
      # The following opts are equivalent to "-q -r -np -nd -N"
      #opts = "--quiet --recursive --no-parent --no-directories --timestamping"
      # Certificate for reactome.org seems to be expired between 20211004 and 20211015
      opts = "--quiet --recursive --no-parent --no-directories --timestamping --no-check-certificate"
      # Also specify output directory by --directory-prefix (-P)
      if glob
        sh "wget #{opts} --directory-prefix #{dir} --accept '#{glob}' #{url}"
      else
        sh "wget #{opts} --directory-prefix #{dir} #{url}"
      end
    end

    # Return true (needs update) when the remote file size is different from the local one
    def check_remote_file_size(file, url)
      if File.exists?(file)
        # The wget --timestamping (-N) option won't check the file size especially when
        # previous download was interrupted and left broken files with newer dates.
        local_file_size  = File.size(file)
        remote_file_size = `curl -sI #{url} | grep '^Content-Length:' | awk '{print $2}'`.strip.to_i
        $stderr.puts "# Local file size:  #{local_file_size} (#{file})"
        $stderr.puts "# Remote file size: #{remote_file_size} (#{url})"
        return local_file_size != remote_file_size
      else
        return true
      end
    end

    # Return true (needs update) when the remote file is newer than the local file
    def check_remote_file_time(file, url)
      if File.exists?(file)
        local_file_time  = File.mtime(file)  # Time object
        remote_file_time = Time.parse(`curl -sI #{url} | grep '^Last-Modified:' | sed -e 's/^Last-Modified: //'`)  # Time object
        $stderr.puts "# Local file time:  #{local_file_time} (#{file})"
        $stderr.puts "# Remote file time: #{remote_file_time} (#{url})"
        return local_file_time < remote_file_time
      else
        return true
      end
    end
  end
end

# Import defined methods to be used in the following rules/tasks (Rake's namespace doesn't separate methods from Object, unfortunatelly)
include TogoID::Main
include TogoID::Prepare

### Update/convert rules

# Note: Because of a quirk in Ruby syntax, parenthesis are required on rule when the first argument is a regular expression
# See https://ruby.github.io/rake/doc/rakefile_rdoc.html

# Dependency for TSV files (check dependency for preparation by target names)
rule(/#{OUTPUT_TSV_DIR}\S+\.tsv/ => [
  OUTPUT_TSV_DIR,
  method(:prepare_task),
  method(:update_tsv)
]) do |t|
  $stderr.puts "Rule for TSV (#{t.name})"
  $stderr.puts t.investigation if $verbose
end

# Dependency for TTL files (generate dependent filenames by pathmap notation)
rule(/#{OUTPUT_TTL_DIR}\S+\.ttl/ => [
  OUTPUT_TTL_DIR,
  "%{#{OUTPUT_TTL_DIR},#{OUTPUT_TSV_DIR}}X.tsv",
  method(:update_ttl)
]) do |t|
  $stderr.puts "Rule for TTL (#{t.name})"
  $stderr.puts t.investigation if $verbose
end

### Preparatioin tasks

namespace :prepare do
  desc "Prepare all"
  task :all => [ :cellosaurus, :ensembl, :homologene, :cog, :interpro, :ncbigene, :reactome, :refseq, :rhea, :sra, :swisslipids, :uniprot, :taxonomy ]

  directory INPUT_DRUGBANK_DIR    = "input/drugbank"
  directory INPUT_CELLOSAURUS_DIR = "input/cellosaurus"
  directory INPUT_ENSEMBL_DIR     = "input/ensembl"
  directory INPUT_HOMOLOGENE_DIR  = "input/homologene"
  directory INPUT_COG_DIR         = "input/cog"
  directory INPUT_INTERPRO_DIR    = "input/interpro"
  directory INPUT_NCBIGENE_DIR    = "input/ncbigene"
  directory INPUT_REACTOME_DIR    = "input/reactome"
  directory INPUT_REFSEQ_DIR      = "input/refseq"
  directory INPUT_RHEA_DIR        = "input/rhea"
  directory INPUT_SRA_DIR         = "input/sra"
  directory INPUT_SWISSLIPIDS_DIR = "input/swisslipids"
  directory INPUT_UNIPROT_DIR     = "input/uniprot"
  directory INPUT_TAXONOMY_DIR    = "input/taxonomy"

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

  desc "Prepare required files for Cellosaurus"
  task :cellosaurus => INPUT_CELLOSAURUS_DIR do
    $stderr.puts "## Prepare input files for Cellosaurus"
    download_lock(INPUT_CELLOSAURUS_DIR) do
      input_file = "#{INPUT_CELLOSAURUS_DIR}/cellosaurus.txt"
      input_url  = "https://ftp.expasy.org/databases/cellosaurus/cellosaurus.txt"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_CELLOSAURUS_DIR, input_url)
      end
    end
  end

  desc "Prepare taxonomy ID list for Ensembl"
  task :ensembl => INPUT_ENSEMBL_DIR do
    $stderr.puts "## Prepare input files for Ensembl"
    download_lock(INPUT_ENSEMBL_DIR) do
      updated = false
      taxonomy_file = "#{INPUT_ENSEMBL_DIR}/taxonomy.txt"
      if file_older_than_days?(taxonomy_file)
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

  desc "Prepare required files for COG"
  task :cog => INPUT_COG_DIR do
    $stderr.puts "## Prepare input files for COG"
    download_lock(INPUT_COG_DIR) do
      updated = false
      input_file = "#{INPUT_COG_DIR}/cog-20.cog.csv"
      input_url  = "ftp://ftp.ncbi.nlm.nih.gov/pub/COG/COG2020/data/cog-20.cog.csv"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_COG_DIR, input_url)
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
      input_url  = "ftp://ftp.ebi.ac.uk/pub/databases/interpro/current_release/interpro2go"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_INTERPRO_DIR, input_url)
        updated = true
      end

      input_file = "#{INPUT_INTERPRO_DIR}/protein2ipr.dat.gz"
      input_url  = "ftp://ftp.ebi.ac.uk/pub/databases/interpro/current_release/protein2ipr.dat.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_INTERPRO_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_INTERPRO_DIR}/protein2ipr.dat"
        updated = true
      end

      input_file = "#{INPUT_INTERPRO_DIR}/interpro.xml.gz"
      input_url  = "ftp://ftp.ebi.ac.uk/pub/databases/interpro/current_release/interpro.xml.gz"
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
        download_file(INPUT_NCBIGENE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_NCBIGENE_DIR}/gene2refseq"
        updated = true
      end

      input_file = "#{INPUT_NCBIGENE_DIR}/gene2ensembl.gz"
      input_url  = "https://ftp.ncbi.nih.gov/gene/DATA/gene2ensembl.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_NCBIGENE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_NCBIGENE_DIR}/gene2ensembl"
        updated = true
      end

      input_file = "#{INPUT_NCBIGENE_DIR}/gene2go.gz"
      input_url  = "https://ftp.ncbi.nih.gov/gene/DATA/gene2go.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_NCBIGENE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_NCBIGENE_DIR}/gene2go"
        updated = true
      end

      input_file = "#{INPUT_NCBIGENE_DIR}/Homo_sapiens.gene_info.gz"
      input_url  = "https://ftp.ncbi.nih.gov/gene/DATA/GENE_INFO/Mammalia/Homo_sapiens.gene_info.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_NCBIGENE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_NCBIGENE_DIR}/Homo_sapiens.gene_info"
        updated = true
      end

      input_file = "#{INPUT_NCBIGENE_DIR}/gene_info.gz"
      input_url  = "https://ftp.ncbi.nih.gov/gene/DATA/gene_info.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_NCBIGENE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_NCBIGENE_DIR}/gene_info"
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for Reactome"
  task :reactome => INPUT_REACTOME_DIR do
    $stderr.puts "## Prepare input files for Reactome"
    download_lock(INPUT_REACTOME_DIR) do
      updated = false
      input_file = "#{INPUT_REACTOME_DIR}/UniProt2ReactomeReactions.txt"
      input_url  = "https://reactome.org/download/current/UniProt2ReactomeReactions.txt"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_REACTOME_DIR, input_url)
        updated = true
      end

      input_file = "#{INPUT_REACTOME_DIR}/ChEBI2ReactomeReactions.txt"
      input_url  = "https://reactome.org/download/current/ChEBI2ReactomeReactions.txt"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_REACTOME_DIR, input_url)
        updated = true
      end

      input_file = "#{INPUT_REACTOME_DIR}/Ensembl2ReactomeReactions.txt"
      input_url  = "https://reactome.org/download/current/Ensembl2ReactomeReactions.txt"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_REACTOME_DIR, input_url)
        updated = true
      end

      input_file = "#{INPUT_REACTOME_DIR}/miRBase2ReactomeReactions.txt"
      input_url  = "https://reactome.org/download/current/miRBase2ReactomeReactions.txt"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_REACTOME_DIR, input_url)
        updated = true
      end

      input_file = "#{INPUT_REACTOME_DIR}/NCBI2ReactomeReactions.txt"
      input_url  = "https://reactome.org/download/current/NCBI2ReactomeReactions.txt"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_REACTOME_DIR, input_url)
        updated = true
      end
      input_file = "#{INPUT_REACTOME_DIR}/GtoP2ReactomeReactions.txt"
      input_url  = "https://reactome.org/download/current/GtoP2ReactomeReactions.txt"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_REACTOME_DIR, input_url)
        updated = true
      end

      input_file = "#{INPUT_REACTOME_DIR}/UniProt2Reactome_All_Levels.txt"
      input_url  = "https://reactome.org/download/current/UniProt2Reactome_All_Levels.txt"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_REACTOME_DIR, input_url)
        updated = true
      end

      input_file = "#{INPUT_REACTOME_DIR}/ChEBI2Reactome_All_Levels.txt"
      input_url  = "https://reactome.org/download/current/ChEBI2Reactome_All_Levels.txt"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_REACTOME_DIR, input_url)
        updated = true
      end

      input_file = "#{INPUT_REACTOME_DIR}/Ensembl2Reactome_All_Levels.txt"
      input_url  = "https://reactome.org/download/current/Ensembl2Reactome_All_Levels.txt"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_REACTOME_DIR, input_url)
        updated = true
      end

      input_file = "#{INPUT_REACTOME_DIR}/miRBase2Reactome_All_Levels.txt"
      input_url  = "https://reactome.org/download/current/miRBase2Reactome_All_Levels.txt"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_REACTOME_DIR, input_url)
        updated = true
      end

      input_file = "#{INPUT_REACTOME_DIR}/NCBI2Reactome_All_Levels.txt"
      input_url  = "https://reactome.org/download/current/NCBI2Reactome_All_Levels.txt"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_REACTOME_DIR, input_url)
        updated = true
      end
      
      input_file = "#{INPUT_REACTOME_DIR}/GtoP2Reactome_All_Levels.txt"
      input_url  = "https://reactome.org/download/current/GtoP2Reactome_All_Levels.txt"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_REACTOME_DIR, input_url)
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
        download_file(INPUT_REFSEQ_DIR, input_url)
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for Rhea"
  task :rhea => INPUT_RHEA_DIR do
    $stderr.puts "## Prepare input files for Rhea"
    download_lock(INPUT_RHEA_DIR) do
      updated = false

      input_file = "#{INPUT_RHEA_DIR}/rhea2uniprot_sprot.tsv"
      input_url  = "https://ftp.expasy.org/databases/rhea/tsv/rhea2uniprot_sprot.tsv"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_RHEA_DIR, input_url)
        updated = true
      end

      input_file = "#{INPUT_RHEA_DIR}/rhea2uniprot_trembl.tsv.gz"
      input_url  = "https://ftp.expasy.org/databases/rhea/tsv/rhea2uniprot_trembl.tsv.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_RHEA_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_RHEA_DIR}/rhea2uniprot_trembl.tsv"
        updated = true
      end

      input_file = "#{INPUT_RHEA_DIR}/rhea2go.tsv"
      input_url  = "https://ftp.expasy.org/databases/rhea/tsv/rhea2go.tsv"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_RHEA_DIR, input_url)
        updated = true
      end

      updated
    end
  end

  desc "Prepare required files for SRA"
  task :sra => INPUT_SRA_DIR do
    $stderr.puts "## Prepare input files for SRA"
    download_lock(INPUT_SRA_DIR) do
      updated = false
      input_file = "#{INPUT_SRA_DIR}/SRA_Accessions.tab"
      input_url  = "https://ftp.ncbi.nlm.nih.gov/sra/reports/Metadata/SRA_Accessions.tab"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_SRA_DIR, input_url)
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for SwissLipids"
  task :swisslipids => INPUT_SWISSLIPIDS_DIR do
    $stderr.puts "## Prepare input files for SwissLipids"
    download_lock(INPUT_SWISSLIPIDS_DIR) do
      updated = false

      input_file = "#{INPUT_SWISSLIPIDS_DIR}/lipids.tsv.gz"
      input_url = "https://www.swisslipids.org/api/file.php?cas=download_files&file=lipids.tsv"
      if update_input_file?(input_file, input_url)
        sh "wget --quiet --no-check-certificate -O #{input_file} '#{input_url}'"
        sh "gzip -dc #{input_file} > #{INPUT_SWISSLIPIDS_DIR}/lipids.tsv"
        updated = true
      end
      updated
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
        download_file(INPUT_UNIPROT_DIR, input_url)
        updated = true
      end
      input_file = "#{INPUT_UNIPROT_DIR}/idmapping_selected.tab.gz"
      input_url  = "ftp://ftp.ebi.ac.uk/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping_selected.tab.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_UNIPROT_DIR, input_url)
        sh "gzip -dc #{INPUT_UNIPROT_DIR}/idmapping_selected.tab.gz | cut -f 1,7 | grep 'GO:' > #{INPUT_UNIPROT_DIR}/idmapping_selected.go"
        updated = true
      end
      sh "wget --quiet --no-check-certificate -O #{INPUT_UNIPROT_DIR}/uniprot_reference_proteome.tab.gz 'https://rest.uniprot.org/proteomes/stream?compressed=true&fields=upid%2Corganism_id%2Cgenome_assembly&format=tsv&query=%28%2A%29'"
      # Not used:
      #input_url  = "ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/UNIPROT/goa_uniprot_all.gaf.gz"
      updated
    end
  end

  desc "Prepare required files for taxonomy"
  task :taxonomy => INPUT_TAXONOMY_DIR do
    $stderr.puts "## Prepare input files for Taxonomy"
    download_lock(INPUT_TAXONOMY_DIR) do
      updated = false
      input_file = "#{INPUT_TAXONOMY_DIR}/taxdump.tar.gz"
      input_url = "https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_TAXONOMY_DIR, input_url)
        sh "mkdir -p #{INPUT_TAXONOMY_DIR}/taxdump && tar xzf #{INPUT_TAXONOMY_DIR}/taxdump.tar.gz -C #{INPUT_TAXONOMY_DIR}/taxdump/"
        updated = true
      end
      updated
    end
  end
end
# Upload task
namespace :aws do
  desc "Create update.txt and upload TSV files to AWS S3"
  task :update => [:create_list, :upload_s3]

  desc "Create update.txt"
  task :create_list => [UPDATE_TXT]

  file UPDATE_TXT do
    begin
      raise NameError if !S3_BUCKET_NAME
      sync_dryrun_stdout = `aws s3 sync --dryrun #{OUTPUT_TSV_DIR}/ s3://#{S3_BUCKET_NAME}/tsv --include \"*tsv\"`
    rescue
      STDERR.puts("ERROR: missing S3 bucket name: use `export S3_BUCKET_NAME=your_bucket_name`")
      exit 1
    end
    update_files = sync_dryrun_stdout.split("\n").map{|line| File.basename(line.split("\s+").last) }
    open(UPDATE_TXT, 'w'){|f| f.puts(update_files) }
  end

  desc "Upload TSV files to AWS S3"
  task :upload_s3 => UPDATE_TXT do
    begin
      raise NameError if !S3_BUCKET_NAME
      system("aws s3 sync #{OUTPUT_TSV_DIR}/ s3://#{S3_BUCKET_NAME}/tsv --include \"*tsv\"")
      system("aws s3 sync #{OUTPUT_TSV_DIR}/ s3://#{S3_BUCKET_NAME}/tsv --include \"update.txt\"")
    rescue NameError
      STDERR.puts("ERROR: missing S3 bucket name: use `export S3_BUCKET_NAME=your_bucket_name`")
      exit 1
    end
  end
end
