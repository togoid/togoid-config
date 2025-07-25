# TogoID

require 'time'
require 'yaml'

ENV['PATH'] = "bin:#{ENV['HOME']}/local/bin:#{ENV['PATH']}"

### Options

$verbose = true  # Flag to enable verbose output for STDERR

# TogoID#file_older_than_days?()
$duration = 5    # Default number of days to force update

# TogoID#validate_tsv_output()
$chklines = 10   # Number of head and tail lines to be validated
$maxblank = 2    # Maximum number of acceptable empty lines in TSV files
$minratio = 0.5  # Minimum acceptable size ratio of new / old TSV file sizes

### Tasks

directory OUTPUT_TSV_DIR = "output/tsv/"
directory OUTPUT_TTL_DIR = "output/ttl/relation/"
directory OUTPUT_ID_LABEL_TTL_DIR = "output/ttl/label/"

CFG_FILES = FileList["config/*/config.yaml"]
TSV_FILES = CFG_FILES.pathmap("%-1d").sub(/^/, OUTPUT_TSV_DIR).sub(/$/, '.tsv')
TTL_FILES = CFG_FILES.pathmap("%-1d").sub(/^/, OUTPUT_TTL_DIR).sub(/$/, '.ttl')

datasets = YAML.load(File.read("config/dataset.yaml"))
id_label_files_strs = []
datasets.each do |dataset, hash|
  if hash.has_key?("method")
    id_label_files_strs.push("#{OUTPUT_ID_LABEL_TTL_DIR}#{dataset}.ttl")
  end
end
ID_LABEL_FILES = FileList.new(id_label_files_strs)

# For update procedure on AWS
UPDATE_TXT     = ENV['TOGOID_UPDATE_TXT'] || File.join(OUTPUT_TSV_DIR, "update.txt")
S3_BUCKET_NAME = ENV['S3_BUCKET_NAME'] || "togo-id-production"

desc "Default task (update & convert)"
#task :default => [ :pre, :update, :convert, :post ]
task :default => [ :pre, 'prepare:all', :update, :convert, :id_label, :post ]
desc "Update all TSV files"
task :update  => TSV_FILES
desc "Update all TTL files"
task :convert => TTL_FILES
desc "Update all ID and label TTL files"
task :id_label => ID_LABEL_FILES

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
          if File.exist?(tsv_file_name(pair))
            # Backup previous TSV output
            sh "mv #{tsv_file_name(pair)} #{tsv_file_name_old(pair)}", verbose: false
          end
          sh "togoid-config #{config_dir_name(pair)} update"
          if validate_tsv_output(pair)
            $stderr.puts "# Success: #{tsv_file_name(pair)} is updated"
            if File.exist?(tsv_file_name_old(pair))
              # Remove previous TSV output
              sh "rm #{tsv_file_name_old(pair)}", verbose: false
            end
          else
            $stderr.puts "# Failure: #{tsv_file_name(pair)} is not updated"
            if File.exist?(tsv_file_name_old(pair))
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

    # Entry point for ID and Label TTL
    def update_id_label(taskname)
      if taskname[/#{OUTPUT_ID_LABEL_TTL_DIR}/]
        name = taskname.sub(/#{OUTPUT_ID_LABEL_TTL_DIR}/, '').sub(/\.ttl$/, '')
        if $verbose
          $verbose = false
          $stderr.puts "### Update ID and Label TTL for #{name} if check_id_label_filesize #{check_id_label_filesize(name)} or check_id_label_timestamp #{check_id_label_timestamp(name)}"
          $verbose = true
        end
        if check_id_label_filesize(name) or check_id_label_timestamp(name)
          $stderr.puts "## Update #{id_label_file_name(name)}"
          $stderr.puts "< #{`date +%FT%T`.strip} #{name}"
          if File.exist?(id_label_file_name(name))
            sh "mv #{id_label_file_name(name)} #{id_label_file_name_old(name)}", verbose: false
          end
          sh "togoid-rdfize-id-label #{name}"
          if validate_id_label_output(name)
            $stderr.puts "# Success: #{id_label_file_name(name)} is updated"
            if File.exist?(id_label_file_name_old(name))
              # Remove previous TTL output
              sh "rm #{id_label_file_name_old(name)}", verbose: false
            end
          else
            $stderr.puts "# Failure: #{id_label_file_name(name)} is not updated"
            if File.exist?(id_label_file_name_old(name))
              # Revert previous TTL output"
              sh "mv #{id_label_file_name_old(name)} #{id_label_file_name(name)}", verbose: false
            end
          end
          $stderr.puts "> #{`date +%FT%T`.strip} #{name}"
        else
          $stderr.puts "# => Preserving #{id_label_file_name(name)}"
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

    def id_label_file_name(name)
      "#{OUTPUT_ID_LABEL_TTL_DIR}#{name}.ttl"
    end

    def id_label_file_name_old(name)
      "#{OUTPUT_ID_LABEL_TTL_DIR}#{name}.ttl.old"
    end

    # Return true (needs update) when the TSV file does not exist or the size is zero
    def check_tsv_filesize(pair)
      output = tsv_file_name(pair)
      return ! (File.exist?(output) and File.size(output) > 0)
    end

    # Return true (needs update) when the TTL file does not exist or the size is zero
    def check_ttl_filesize(pair)
      output = ttl_file_name(pair)
      return ! (File.exist?(output) and File.size(output) > 0)
    end

    # Return true (needs update) when the TTL file does not exist or the size is zero
    def check_id_label_filesize(name)
      output = id_label_file_name(name)
      return ! (File.exist?(output) and File.size(output) > 0)
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

    # Return true (needs update) when the TSV file is older than the timestamp file
    def check_id_label_timestamp(name)
      input  = "input/#{name}/download.lock"
      output = id_label_file_name(name)
      # If there is no timpestamp file (input), update the pair anyway
      file_older_than_stamp?(output, input)
    end

    # Return true (needs update) unless the output file exists and newer than the given timestamp file (if available)
    def file_older_than_stamp?(file, stamp)
      if File.exist?(file) && File.exist?(stamp) && File.mtime(file) > File.mtime(stamp)
        $stderr.puts "# File #{file} is newer than #{stamp}" if $verbose
        false
      else
        if File.exist?(stamp)
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
      if File.exist?(file)
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
      if File.exist?(tsv) and File.exist?(old)
        ratio = 1.0 * File.size(tsv) / File.size(old)
        # New file is not smaller than a half of old file size
        if ratio < $minratio
          $stderr.puts "# Error: #{tsv} new file size per old #{File.size(tsv)} / #{File.size(old)} = #{ratio} < #{$minratio}" if $verbose
          check = false
        end
      end
      # Check if new TSV is valid (regardless of the previous TSV output exists or not)
      if File.exist?(tsv) and File.size(tsv) > 0
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

    def validate_id_label_output(name)
      ttl = id_label_file_name(name)
      old = id_label_file_name_old(name)
      check = true
      if File.exist?(ttl) and File.exist?(old)
        ratio = 1.0 * File.size(ttl) / File.size(old)
        # New file is not smaller than a half of old file size
        if ratio < $minratio
          $stderr.puts "# Error: #{ttl} new file size per old #{File.size(ttl)} / #{File.size(old)} = #{ratio} < #{$minratio}" if $verbose
          check = false
        end
      end
      # Check if new TTL is valid
      if check and File.exist?(ttl) and File.size(ttl) > 0
        # For large files, to avoid rapper's OOM, split files.
        if File.size(ttl) > 1_000_000_000
          chunk_size = 10_000_000
          sh "awk -v lim=#{chunk_size} 'BEGIN{filenum=0}/^@prefix/{prefix=prefix \"\\n\" $0;next}$1{if(n%lim==0){file=FILENAME \".temp.\" filenum; filenum++ ;n=0; print prefix >> file};n++; print >> file}' #{ttl}"
          split_files = Dir.glob(ttl + ".temp.*")
          for split_file in split_files
            puts split_file
            sh "rapper -i turtle -c #{split_file}" do |ok, status|
              if !ok
                $stderr.puts "# Error: #{ttl} is not valid" if $verbose
                check = false
                break
              end
            end
            sh "rm #{split_file}"
          end
        else
          sh "rapper -i turtle -c #{ttl}" do |ok, status|
            if !ok
              $stderr.puts "# Error: #{ttl} is not valid" if $verbose
              check = false
            end
          end
        end
      else
        if check
          $stderr.puts "# Error: Failed to create #{ttl} or created file was empty" if $verbose
          check = false
        end
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
      when /#{OUTPUT_TSV_DIR}bioproject/
        return "prepare:bioproject"
      when /#{OUTPUT_TSV_DIR}biosample/
        return "prepare:biosample"
      when /#{OUTPUT_TSV_DIR}cellosaurus/
        return "prepare:cellosaurus"
      when /#{OUTPUT_TSV_DIR}clinvar/
        return "prepare:clinvar"
      when /#{OUTPUT_TSV_DIR}ensembl/
        return "prepare:ensembl"
      when /#{OUTPUT_TSV_DIR}flybase/
        return "prepare:flybase"
      when /#{OUTPUT_TSV_DIR}glytoucan/
        return "prepare:glytoucan"
      when /#{OUTPUT_TSV_DIR}hgnc/
        return "prepare:hgnc"
      when /#{OUTPUT_TSV_DIR}hmdb/
        return "prepare:hmdb"
      when /#{OUTPUT_TSV_DIR}homologene/
        return "prepare:homologene"
      when /#{OUTPUT_TSV_DIR}hp_phenotype/
        return "prepare:hp_phenotype"
      when /#{OUTPUT_TSV_DIR}cog/
        return "prepare:cog"
      when /#{OUTPUT_TSV_DIR}interpro/
        return "prepare:interpro"
      when /#{OUTPUT_TSV_DIR}lipidmaps/
        return "prepare:lipidmaps"
      when /#{OUTPUT_TSV_DIR}mgi_gene/
        return "prepare:mgi_gene"
      when /#{OUTPUT_TSV_DIR}mgi_genotype/
        return "prepare:mgi_genotype"
      when /#{OUTPUT_TSV_DIR}mirbase/
        return "prepare:mirbase"
      when /#{OUTPUT_TSV_DIR}ncbigene/
        return "prepare:ncbigene"
      when /#{OUTPUT_TSV_DIR}oma_protein/
        return "prepare:oma_protein"
      when /#{OUTPUT_TSV_DIR}orphanet_phenotype/
        return "prepare:orphanet_phenotype"
      when /#{OUTPUT_TSV_DIR}pmc/
        return "prepare:pmc"
      when /#{OUTPUT_TSV_DIR}prosite/
        return "prepare:prosite"
      when /#{OUTPUT_TSV_DIR}reactome/
        return "prepare:reactome"
      when /#{OUTPUT_TSV_DIR}refseq_protein/
        return "prepare:refseq_protein"
      when /#{OUTPUT_TSV_DIR}refseq_rna/
        return "prepare:refseq_rna"
      when /#{OUTPUT_TSV_DIR}rhea/
        return "prepare:rhea"
      when /#{OUTPUT_TSV_DIR}rnacentral/
        return "prepare:rnacentral"
      when /#{OUTPUT_TSV_DIR}sra/
        return "prepare:sra"
      when /#{OUTPUT_TSV_DIR}swisslipids/
        return "prepare:swisslipids"
      when /#{OUTPUT_TSV_DIR}uniprot/
        return "prepare:uniprot"
      when /#{OUTPUT_TSV_DIR}taxonomy/
        return "prepare:taxonomy"
      when /#{OUTPUT_TSV_DIR}zfin/
        return "prepare:zfin"
      else
        File.open("input/update.txt", "w")
        return "input/update.txt"
      end
    end

    # Check if the file is updated or the sizes differ or the file doesn't exist
    def update_input_file?(file, url)
      if File.exist?(file)
        # Both checks should be made as the local file can be newer than remote when the previous download fails
        # and the local file can be smaller or size 0 even when it exists
        check_remote_file_time(file, url) || check_remote_file_size(file, url)
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
      begin
        if glob
          sh "wget #{opts} --directory-prefix #{dir} --accept '#{glob}' #{url}"
        else
          sh "wget #{opts} --directory-prefix #{dir} #{url}"
        end
      rescue StandardError => e
          $stderr.puts "Error: download_file(#{dir}, #{url}): #{e.message}"
      end
    end

    # Return true (needs update) when the remote file size is different from the local one
    def check_remote_file_size(file, url)
      if File.exist?(file)
        # The wget --timestamping (-N) option won't check the file size especially when
        # previous download was interrupted and left broken files with newer dates.
        local_file_size  = File.size(file)
        remote_file_size = `curl -sIL #{url} | grep -i '^content-length:' | tail -1 | awk '{print $2}'`.strip.to_i
        $stderr.puts "# Local file size:  #{local_file_size} (#{file})"
        $stderr.puts "# Remote file size: #{remote_file_size} (#{url})"
        if remote_file_size == 0
          $stderr.puts "Error: Remote file is empty"
          return false
        end
        return local_file_size != remote_file_size
      else
        return true
      end
    end

    # Return true (needs update) when the remote file is newer than the local file
    def check_remote_file_time(file, url)
      if File.exist?(file)
        local_file_time  = File.mtime(file)  # Time object
        begin
          remote_file_time = Time.parse(`curl -sIL #{url} | grep -i '^last-modified:' | tail -1 | sed -e 's/^[Ll]ast-[Mm]odified: //'`)  # Time object
        rescue ArgumentError => e
          $stderr.puts "Error: check_remote_file_time(#{file}, #{url}): #{e.message}"
          return false
        end
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
  method(:prepare_task)
]) do |t|
  update_tsv(t.name)
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

# Dependency for ID and Label TTL files
rule(/#{OUTPUT_ID_LABEL_TTL_DIR}\S+\.ttl/ => [
  OUTPUT_ID_LABEL_TTL_DIR,
  method(:update_id_label)
]) do |t|
  $stderr.puts "Rule for ID and Label TTL (#{t.name})"
  $stderr.puts t.investigation if $verbose
end

### Preparatioin tasks

namespace :prepare do
  desc "Prepare all"
  task :all => [ :bioproject, :biosample, :cellosaurus, :clinvar, :ensembl, :flybase, :glytoucan, :hmdb, :hgnc, :homologene, :hp_phenotype, :cog, :interpro, :lipidmaps, :mgi_gene, :mgi_genotype, :mirbase, :ncbigene, :oma_protein, :orphanet_phenotype, :pmc, :prosite, :reactome, :refseq_protein, :refseq_rna, :rhea, :rnacentral, :sra, :swisslipids, :uniprot, :taxonomy, :zfin ]

  directory INPUT_DRUGBANK_DIR    = "input/drugbank"
  directory INPUT_BIOPROJECT_DIR  = "input/bioproject"
  directory INPUT_BIOSAMPLE_DIR  = "input/biosample"
  directory INPUT_CELLOSAURUS_DIR = "input/cellosaurus"
  directory INPUT_CLINVAR_DIR     = "input/clinvar"
  directory INPUT_ENSEMBL_DIR     = "input/ensembl"
  directory INPUT_FLYBASE_DIR     = "input/flybase"
  directory INPUT_HOMOLOGENE_DIR  = "input/homologene"
  directory INPUT_HP_PHENOTYPE_DIR  = "input/hp_phenotype"
  directory INPUT_COG_DIR         = "input/cog"
  directory INPUT_GLYTOUCAN_DIR   = "input/glytoucan"
  directory INPUT_HMDB_DIR        = "input/hmdb"
  directory INPUT_HGNC_DIR        = "input/hgnc"
  directory INPUT_INTERPRO_DIR    = "input/interpro"
  directory INPUT_LIPIDMAPS_DIR   = "input/lipidmaps"
  directory INPUT_MGI_GENE_DIR    = "input/mgi_gene"
  directory INPUT_MGI_GENOTYPE_DIR    = "input/mgi_genotype"
  directory INPUT_MIRBASE_DIR    = "input/mirbase"
  directory INPUT_NCBIGENE_DIR    = "input/ncbigene"
  directory INPUT_OMA_PROTEIN_DIR = "input/oma_protein"
  directory INPUT_ORPHANET_PHENOTYPE_DIR = "input/orphanet_phenotype"
  directory INPUT_PROSITE_DIR     = "input/prosite"
  directory INPUT_PMC_DIR     = "input/pmc"
  directory INPUT_REACTOME_DIR    = "input/reactome"
  directory INPUT_REFSEQ_PROTEIN_DIR  = "input/refseq_protein"
  directory INPUT_REFSEQ_RNA_DIR  = "input/refseq_rna"
  directory INPUT_RHEA_DIR        = "input/rhea"
  directory INPUT_RNACENTRAL_DIR  = "input/rnacentral"
  directory INPUT_SRA_DIR         = "input/sra"
  directory INPUT_SWISSLIPIDS_DIR = "input/swisslipids"
  directory INPUT_UNIPROT_DIR     = "input/uniprot"
  directory INPUT_TAXONOMY_DIR    = "input/taxonomy"
  directory INPUT_ZFIN_DIR        = "input/zfin"

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

  desc "Prepare required files for BioProject"
  task :bioproject => INPUT_BIOPROJECT_DIR do
    $stderr.puts "## Prepare input files for BioProject"
    download_lock(INPUT_BIOPROJECT_DIR) do
      updated = false
      input_file = "#{INPUT_BIOPROJECT_DIR}/bioproject.xml"
      input_url  = "https://ftp.ncbi.nlm.nih.gov/bioproject/bioproject.xml"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_BIOPROJECT_DIR, input_url)
        sh "python bin/bioproject_xml2tsv.py #{INPUT_BIOPROJECT_DIR}/bioproject.xml > #{INPUT_BIOPROJECT_DIR}/bioproject.tsv"
        updated = true
      end

      input_file = "#{INPUT_BIOPROJECT_DIR}/bioproject2biosample.tsv"
      input_url  = "https://ddbj.nig.ac.jp/public/dblink/bioproject-biosample/bioproject2biosample.tsv"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_BIOPROJECT_DIR, input_url)
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for BioSample"
  task :biosample => INPUT_BIOSAMPLE_DIR do
    $stderr.puts "## Prepare input files for BioSample"
    download_lock(INPUT_BIOSAMPLE_DIR) do
      updated = false
      input_file = "#{INPUT_BIOSAMPLE_DIR}/biosample_set.xml.gz"
      input_url  = "https://ftp.ncbi.nlm.nih.gov/biosample/biosample_set.xml.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_BIOSAMPLE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_BIOSAMPLE_DIR}/biosample_set.xml"
        sh "python bin/biosample_xml2tsv.py #{INPUT_BIOSAMPLE_DIR}/biosample_set.xml > #{INPUT_BIOSAMPLE_DIR}/biosample_set.tsv"
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for Cellosaurus"
  task :cellosaurus => INPUT_CELLOSAURUS_DIR do
    $stderr.puts "## Prepare input files for Cellosaurus"
    download_lock(INPUT_CELLOSAURUS_DIR) do
      updated = false
      input_file = "#{INPUT_CELLOSAURUS_DIR}/cellosaurus.txt"
      input_url  = "https://ftp.expasy.org/databases/cellosaurus/cellosaurus.txt"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_CELLOSAURUS_DIR, input_url)
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for ClinVar"
  task :clinvar => INPUT_CLINVAR_DIR do
    $stderr.puts "## Prepare input files for ClinVar"
    download_lock(INPUT_CLINVAR_DIR) do
      updated = false
      input_file = "#{INPUT_CLINVAR_DIR}/variant_summary.txt.gz"
      input_url  = "https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/variant_summary.txt.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_CLINVAR_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_CLINVAR_DIR}/variant_summary.txt"
        updated = true
      end
      updated
    end
  end

  desc "Prepare taxonomy ID list for Ensembl"
  task :ensembl => INPUT_ENSEMBL_DIR do
    $stderr.puts "## Prepare input files for Ensembl"
    download_lock(INPUT_ENSEMBL_DIR) do
      updated = false
      taxonomy_file = "#{INPUT_ENSEMBL_DIR}/taxonomy.txt"
      if file_older_than_days?(taxonomy_file)
        sh "sparql_csv2tsv.sh #{INPUT_ENSEMBL_DIR}/taxonomy.rq https://rdfportal.org/ebi/sparql > #{taxonomy_file}"
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for FlyBase"
  task :flybase => INPUT_FLYBASE_DIR do
    $stderr.puts "## Prepare input files for FlyBase"
    download_lock(INPUT_FLYBASE_DIR) do
      updated = false

      begin
        sh "wget https://s3ftp.flybase.org/releases/current/precomputed_files/genes/ --no-remove-listing --directory-prefix=#{INPUT_FLYBASE_DIR}"
        current_filename = `grep -oP "fbgn_fbtr_fbpp_expanded_fb_.*?\.tsv\.gz" #{INPUT_FLYBASE_DIR}/index.html | head -1`.strip
        input_file = "#{INPUT_FLYBASE_DIR}/#{current_filename}"
      rescue StandardError => e
        $stderr.puts "Error: wget: #{e.message}"
        input_file = ""
      end

      if input_file != "" && !File.exist?(input_file)
        sh "rm -f #{INPUT_FLYBASE_DIR}/fbgn_fbtr_fbpp_expanded_fb_*.tsv.gz"
        input_url = "https://s3ftp.flybase.org/releases/current/precomputed_files/genes/#{current_filename}"
        download_file(INPUT_FLYBASE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_FLYBASE_DIR}/fbgn_fbtr_fbpp_expanded_fb_current.tsv"
        updated = true
      end
      sh "rm -f #{INPUT_FLYBASE_DIR}/index.html"
      updated
    end
  end

  desc "Prepare required files for GlyTouCan"
  task :glytoucan => INPUT_GLYTOUCAN_DIR do
    $stderr.puts "## Prepare input files for GlyTouCan"
    download_lock(INPUT_GLYTOUCAN_DIR) do
      updated = false
      input_file = "#{INPUT_GLYTOUCAN_DIR}/glycosmos_ggdbs_pubmed.csv"
      input_url  = "https://glycosmos.org/download/glycosmos_ggdbs_pubmed.csv"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_GLYTOUCAN_DIR, input_url)
        sh "sparql_csv2tsv.sh bin/sparql/glycogene-uniprot.rq https://ts.glycosmos.org/sparql > #{INPUT_GLYTOUCAN_DIR}/glycogene-uniprot.tsv"
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for HGNC"
  task :hgnc => INPUT_HGNC_DIR do
    $stderr.puts "## Prepare input files for HGNC"
    download_lock(INPUT_HGNC_DIR) do
      updated = false
      input_file = "#{INPUT_HGNC_DIR}/hgnc_complete_set.txt"
      input_url  = "https://storage.googleapis.com/public-download-files/hgnc/tsv/tsv/hgnc_complete_set.txt"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_HGNC_DIR, input_url)
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for HMDB"
  task :hmdb => INPUT_HMDB_DIR do
    $stderr.puts "## Prepare input files for HMDB"
    download_lock(INPUT_HMDB_DIR) do
      updated = false
      input_file = "#{INPUT_HMDB_DIR}/hmdb_metabolites.zip"
      input_url  = "https://hmdb.ca/system/downloads/current/hmdb_metabolites.zip"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_HMDB_DIR, input_url)
        sh "unzip #{input_file} -d #{INPUT_HMDB_DIR}/"
        sh "python bin/hmdb_xml2tsv_sax.py #{INPUT_HMDB_DIR}/hmdb_metabolites.xml > #{INPUT_HMDB_DIR}/hmdb_metabolites.tsv"
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
      input_url  = "https://ftp.ncbi.nlm.nih.gov/pub/HomoloGene/current/homologene.data"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_HOMOLOGENE_DIR, input_url)
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for HP Phenotype"
  task :hp_phenotype => INPUT_HP_PHENOTYPE_DIR do
    $stderr.puts "## Prepare input files for HP Phenotype"
    download_lock(INPUT_HP_PHENOTYPE_DIR) do
      updated = false
      input_file = "#{INPUT_HP_PHENOTYPE_DIR}/phenotype.hpoa"
      input_url  = "http://purl.obolibrary.org/obo/hp/hpoa/phenotype.hpoa"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_HP_PHENOTYPE_DIR, input_url)
        updated = true
      end

      input_file = "#{INPUT_HP_PHENOTYPE_DIR}/genes_to_phenotype.txt"
      input_url  = "http://purl.obolibrary.org/obo/hp/hpoa/genes_to_phenotype.txt"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_HP_PHENOTYPE_DIR, input_url)
        updated = true
      end
      sh "bin/sparql_csv2tsv.sh bin/sparql/hp_category.rq https://rdfportal.org/bioportal/sparql > #{INPUT_HP_PHENOTYPE_DIR}/hp_category.tsv"
      updated
    end
  end

  desc "Prepare required files for COG"
  task :cog => INPUT_COG_DIR do
    $stderr.puts "## Prepare input files for COG"
    download_lock(INPUT_COG_DIR) do
      updated = false
      input_file = "#{INPUT_COG_DIR}/cog-20.cog.csv"
      input_url  = "https://ftp.ncbi.nlm.nih.gov/pub/COG/COG2020/data/cog-20.cog.csv"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_COG_DIR, input_url)
        updated = true
      end
      input_file = "#{INPUT_COG_DIR}/cog-20.def.tab"
      input_url  = "https://ftp.ncbi.nlm.nih.gov/pub/COG/COG2020/data/cog-20.def.tab"
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
      input_url  = "https://ftp.ebi.ac.uk/pub/databases/interpro/current_release/interpro2go"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_INTERPRO_DIR, input_url)
        updated = true
      end

      input_file = "#{INPUT_INTERPRO_DIR}/protein2ipr.dat.gz"
      input_url  = "https://ftp.ebi.ac.uk/pub/databases/interpro/current_release/protein2ipr.dat.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_INTERPRO_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_INTERPRO_DIR}/protein2ipr.dat"
        updated = true
      end

      input_file = "#{INPUT_INTERPRO_DIR}/interpro.xml.gz"
      input_url  = "https://ftp.ebi.ac.uk/pub/databases/interpro/current_release/interpro.xml.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_INTERPRO_DIR, input_url)
        sh "gzip -dc #{input_file} | python bin/interpro_xml2tsv.py > #{INPUT_INTERPRO_DIR}/interpro.tsv"
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for LIPID MAPS"
  task :lipidmaps => INPUT_LIPIDMAPS_DIR do
    $stderr.puts "## Prepare input files for LIPID MAPS"
    download_lock(INPUT_LIPIDMAPS_DIR) do
      updated = false
      input_file = "#{INPUT_LIPIDMAPS_DIR}/sdf.zip"
      input_url  = "\"https://www.lipidmaps.org/files/?file=LMSD&ext=sdf.zip\""
      ## Do not check the file size and the timestamp because they are not available in the http header.
      ## As a result, the lipidmaps related pairs will be always updated.
      opts = "--quiet --no-check-certificate"
      begin
        sh "wget #{opts} -O #{INPUT_LIPIDMAPS_DIR}/sdf.zip #{input_url}"
      rescue StandardError => e
        $stderr.puts "Error: download_file(#{INPUT_LIPIDMAPS_DIR}, #{input_url}): #{e.message}"
      end
      sh "unzip -o #{input_file} -d #{INPUT_LIPIDMAPS_DIR}/"
      sh "awk -f bin/parse_lipidmaps_sdf.awk #{INPUT_LIPIDMAPS_DIR}/structures.sdf > #{INPUT_LIPIDMAPS_DIR}/lipidmaps.tsv"
      updated = true

      updated
    end
  end

  desc "Prepare required files for MGI gene"
  task :mgi_gene => INPUT_MGI_GENE_DIR do
    $stderr.puts "## Prepare input files for MGI_GENE"
    download_lock(INPUT_MGI_GENE_DIR) do
      updated = false
      filenames = ["MRK_List2.rpt",
                   "MGI_Gene_Model_Coord.rpt",
                   "MRK_SwissProt_TrEMBL.rpt",
                   "HGNC_AllianceHomology.rpt",
                   "MGI_PhenotypicAllele.rpt"]
      filenames.each do |filename|
        input_file = "#{INPUT_MGI_GENE_DIR}/#{filename}"
        input_url  = "https://www.informatics.jax.org/downloads/reports/#{filename}"
        if update_input_file?(input_file, input_url)
          download_file(INPUT_MGI_GENE_DIR, input_url)
          updated = true
        end
      end
      updated
    end
  end

  desc "Prepare required files for MGI genotype"
  task :mgi_genotype => INPUT_MGI_GENOTYPE_DIR do
    $stderr.puts "## Prepare input files for MGI_GENOTYPE"
    download_lock(INPUT_MGI_GENOTYPE_DIR) do
      updated = false
      filenames = ["MGI_DiseaseGeneModel.rpt"]
      filenames.each do |filename|
        input_file = "#{INPUT_MGI_GENOTYPE_DIR}/#{filename}"
        input_url  = "https://www.informatics.jax.org/downloads/reports/#{filename}"
        if update_input_file?(input_file, input_url)
          download_file(INPUT_MGI_GENOTYPE_DIR, input_url)
          updated = true
        end
      end
      if updated
        sh "ruby bin/query_mousemine.rb > #{INPUT_MGI_GENOTYPE_DIR}/mousemine_genotype.tsv"
      end
      updated
    end
  end

  desc "Prepare required files for miRBase"
  task :mirbase => INPUT_MIRBASE_DIR do
    $stderr.puts "## Prepare input files for miRBase"
    download_lock(INPUT_MIRBASE_DIR) do
      updated = false
      filenames = ["mirna.txt", "mirna_mature.txt", "mirna_pre_mature.txt"]
      filenames.each do |filename|
        input_file = "#{INPUT_MIRBASE_DIR}/#{filename}"
        input_url  = "https://www.mirbase.org/download/CURRENT/database_files/#{filename}"
        if update_input_file?(input_file, input_url)
          download_file(INPUT_MIRBASE_DIR, input_url)
          tsv_filename = input_file.sub(/\.txt$/, '.tsv')
          sh "sed -E 's@<br>@\\n@g; s@</?p>@@g' #{input_file} | awk '$0' > #{tsv_filename}"
          updated = true
        end
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
      input_url  = "https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2refseq.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_NCBIGENE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_NCBIGENE_DIR}/gene2refseq"
        updated = true
      end

      input_file = "#{INPUT_NCBIGENE_DIR}/gene2ensembl.gz"
      input_url  = "https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2ensembl.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_NCBIGENE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_NCBIGENE_DIR}/gene2ensembl"
        updated = true
      end

      input_file = "#{INPUT_NCBIGENE_DIR}/gene2go.gz"
      input_url  = "https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2go.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_NCBIGENE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_NCBIGENE_DIR}/gene2go"
        updated = true
      end

      input_file = "#{INPUT_NCBIGENE_DIR}/Homo_sapiens.gene_info.gz"
      input_url  = "https://ftp.ncbi.nlm.nih.gov/gene/DATA/GENE_INFO/Mammalia/Homo_sapiens.gene_info.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_NCBIGENE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_NCBIGENE_DIR}/Homo_sapiens.gene_info"
        updated = true
      end

      input_file = "#{INPUT_NCBIGENE_DIR}/gene_info.gz"
      input_url  = "https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_info.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_NCBIGENE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_NCBIGENE_DIR}/gene_info"
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for OMA protein"
  task :oma_protein => INPUT_OMA_PROTEIN_DIR do
    $stderr.puts "## Prepare input files for OMA protein"
    download_lock(INPUT_OMA_PROTEIN_DIR) do
      updated = false
      filenames = ["oma-entrez.txt.gz",
                   "oma-species.txt",
                   "oma-uniprot.txt.gz"]
      filenames.each do |filename|
        input_file = "#{INPUT_OMA_PROTEIN_DIR}/#{filename}"
        input_url  = "https://omabrowser.org/All/#{filename}"
        if update_input_file?(input_file, input_url)
          download_file(INPUT_OMA_PROTEIN_DIR, input_url)
          updated = true
        end
      end

      ensembl_taxonomy_file = "#{INPUT_OMA_PROTEIN_DIR}/ensembl_vertebrate_taxonomy.txt"
      oma_ensembl_taxonomy_file = "#{INPUT_OMA_PROTEIN_DIR}/oma_ensembl_vertebrate_taxonomy.txt"
      if updated || !File.exist?(ensembl_taxonomy_file)
        sh "sparql_csv2tsv.sh #{INPUT_ENSEMBL_DIR}/taxonomy.rq https://rdfportal.org/ebi/sparql > #{ensembl_taxonomy_file}"
        sh "awk -F \"\t\" 'FNR==NR{a[$1]=1;next} a[$3]{print $3}' #{ensembl_taxonomy_file} #{INPUT_OMA_PROTEIN_DIR}/oma-species.txt > #{oma_ensembl_taxonomy_file}"
        updated = true
      end

      updated
    end
  end

  desc "Prepare required files for Orphanet phenotype"
  task :orphanet_phenotype => INPUT_ORPHANET_PHENOTYPE_DIR do
    $stderr.puts "## Prepare input files for Orphanet phenotype"
    download_lock(INPUT_ORPHANET_PHENOTYPE_DIR) do
      updated = false
      input_file = "#{INPUT_ORPHANET_PHENOTYPE_DIR}/Homo_sapiens.gene_info.gz"
      input_url  = "https://ftp.ncbi.nlm.nih.gov/gene/DATA/GENE_INFO/Mammalia/Homo_sapiens.gene_info.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_ORPHANET_PHENOTYPE_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_ORPHANET_PHENOTYPE_DIR}/Homo_sapiens.gene_info"
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for PROSITE"
  task :prosite => INPUT_PROSITE_DIR do
    $stderr.puts "## Prepare input files for PROSITE"
    download_lock(INPUT_PROSITE_DIR) do
      updated = false
      input_file = "#{INPUT_PROSITE_DIR}/prosite.dat"
      input_url  = "https://ftp.expasy.org/databases/prosite/prosite.dat"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_PROSITE_DIR, input_url)
        updated = true
      end

      input_file = "#{INPUT_PROSITE_DIR}/prorule.dat"
      input_url  = "https://ftp.expasy.org/databases/prosite/prorule.dat"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_PROSITE_DIR, input_url)
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for PMC"
  task :pmc => INPUT_PMC_DIR do
    $stderr.puts "## Prepare input files for PMC"
    download_lock(INPUT_PMC_DIR) do
      updated = false
      input_file = "#{INPUT_PMC_DIR}/PMC-ids.csv.gz"
      input_url  = "https://ftp.ncbi.nlm.nih.gov/pub/pmc/PMC-ids.csv.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_PMC_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_PMC_DIR}/PMC-ids.csv"
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

      files = [
        "UniProt2ReactomeReactions.txt",
        "ChEBI2ReactomeReactions.txt",
        "Ensembl2ReactomeReactions.txt",
        "miRBase2ReactomeReactions.txt",
        "NCBI2ReactomeReactions.txt",
        "GtoP2ReactomeReactions.txt",
        "UniProt2Reactome_All_Levels.txt",
        "ChEBI2Reactome_All_Levels.txt",
        "Ensembl2Reactome_All_Levels.txt",
        "miRBase2Reactome_All_Levels.txt",
        "NCBI2Reactome_All_Levels.txt",
        "GtoP2Reactome_All_Levels.txt"
      ]
      for file in files do
        input_file = "#{INPUT_REACTOME_DIR}/#{file}"
        input_url  = "https://reactome.org/download/current/#{file}"
        if update_input_file?(input_file, input_url)
          download_file(INPUT_REACTOME_DIR, input_url)
          updated = true
        end
      end

      updated
    end
  end

  desc "Prepare required files for RefSeq RNA"
  task :refseq_rna => INPUT_REFSEQ_RNA_DIR do
    $stderr.puts "## Prepare input files for RefSeq RNA"
    download_lock(INPUT_REFSEQ_RNA_DIR) do
      updated = false
      input_file = "#{INPUT_REFSEQ_RNA_DIR}/RELEASE_NUMBER"
      input_url  = "https://ftp.ncbi.nlm.nih.gov/refseq/release/RELEASE_NUMBER"
      if update_input_file?(input_file, input_url)
        # If the RELEASE_NUMBER file is updated, fetch it and then download required data.
        download_file(INPUT_REFSEQ_RNA_DIR, input_url)
        # The index number of the gbff files (e.g. '1000' of 'complete.1000.rna.gbff.gz') is not stable.
        # To keep the input directory up-to-date, delete all previous files before downloading the current files.
        sh "rm -f #{INPUT_REFSEQ_RNA_DIR}/complete.*.rna.gbff.gz"
        # Unfortunately, NCBI http/https server won't accept wildcard or --accept option.
        # However, NCBI ftp server is currently broken.. You've Been Warned.
        # (It is reported that large files are contaminated by illegal bytes occationally)
        input_file = "complete.*.rna.gbff.gz"
        input_url  = "ftp://ftp.ncbi.nlm.nih.gov:/refseq/release/complete/"
        download_file(INPUT_REFSEQ_RNA_DIR, input_url, input_file)

        # Parse the gbff files and output all relations to a single tsv.
        # Each config extract columns from the tsv.
        sh "gzip -dc #{INPUT_REFSEQ_RNA_DIR}/#{input_file} | parse_refseq_rna_gbff.pl --summary > #{INPUT_REFSEQ_RNA_DIR}/refseq_rna_summary.tsv"
        updated = true
      end
      updated
    end
  end

  desc "Prepare required files for RefSeq Protein"
  task :refseq_protein => INPUT_REFSEQ_PROTEIN_DIR do
    $stderr.puts "## Prepare input files for RefSeq Protein"
    download_lock(INPUT_REFSEQ_PROTEIN_DIR) do
      updated = false

      input_file = "#{INPUT_REFSEQ_PROTEIN_DIR}/gene_refseq_uniprotkb_collab.gz"
      input_url  = "https://ftp.ncbi.nlm.nih.gov/refseq/uniprotkb/gene_refseq_uniprotkb_collab.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_REFSEQ_PROTEIN_DIR, input_url)
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

  desc "Prepare required files for RNAcentral"
  task :rnacentral => INPUT_RNACENTRAL_DIR do
    $stderr.puts "## Prepare input files for RNAcentral"
    download_lock(INPUT_RNACENTRAL_DIR) do
      updated = false

      input_file = "#{INPUT_RNACENTRAL_DIR}/id_mapping.tsv.gz"
      input_url  = "https://ftp.ebi.ac.uk/pub/databases/RNAcentral/current_release/id_mapping/id_mapping.tsv.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_RNACENTRAL_DIR, input_url)
        sh "gzip -dc #{input_file} | sed -e 's/\r//g' > #{INPUT_RNACENTRAL_DIR}/id_mapping.tsv"
        updated = true
      end

      input_file = "#{INPUT_RNACENTRAL_DIR}/rnacentral.gpi.gz"
      input_url  = "https://ftp.ebi.ac.uk/pub/databases/RNAcentral/current_release/gpi/rnacentral.gpi.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_RNACENTRAL_DIR, input_url)
        sh "gzip -dc #{input_file} > #{INPUT_RNACENTRAL_DIR}/rnacentral.gpi"
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
      sh "wget --quiet --no-check-certificate -O #{input_file} '#{input_url}'"
      sh "gzip -dc #{input_file} > #{INPUT_SWISSLIPIDS_DIR}/lipids.tsv"

      input_file = "#{INPUT_SWISSLIPIDS_DIR}/lipids2uniprot.tsv.gz"
      input_url = "https://www.swisslipids.org/api/file.php?cas=download_files&file=lipids2uniprot.tsv"
      sh "wget --quiet --no-check-certificate -O #{input_file} '#{input_url}'"
      sh "gzip -dc #{input_file} > #{INPUT_SWISSLIPIDS_DIR}/lipids2uniprot.tsv"
      updated = true
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
      input_url  = "https://ftp.ebi.ac.uk/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping.dat.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_UNIPROT_DIR, input_url)
        updated = true
      end
      input_file = "#{INPUT_UNIPROT_DIR}/idmapping_selected.tab.gz"
      input_url  = "https://ftp.ebi.ac.uk/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping_selected.tab.gz"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_UNIPROT_DIR, input_url)
        sh "gzip -dc #{INPUT_UNIPROT_DIR}/idmapping_selected.tab.gz | cut -f 1,7 | grep 'GO:' > #{INPUT_UNIPROT_DIR}/idmapping_selected.go"
        updated = true
      end
      begin
        sh "wget --quiet --no-check-certificate -O #{INPUT_UNIPROT_DIR}/uniprot_proteome.tab.gz 'https://rest.uniprot.org/proteomes/stream?compressed=true&fields=upid%2Corganism_id%2Cgenome_assembly%2Corganism&format=tsv&query=%28%2A%29'"
      rescue StandardError => e
        $stderr.puts "Error: prepare uniprot_proteome: #{e.message}"
      end
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

  desc "Prepare required files for ZFIN"
  task :zfin => INPUT_ZFIN_DIR do
    $stderr.puts "## Prepare input files for ZFIN"
    download_lock(INPUT_ZFIN_DIR) do
      updated = false
      input_file = "#{INPUT_ZFIN_DIR}/transcripts.txt"
      input_url = "https://zfin.org/downloads/transcripts.txt"
      if update_input_file?(input_file, input_url)
        download_file(INPUT_ZFIN_DIR, input_url)
        updated = true
      end
      updated
    end
  end
end

# Upload task
namespace :aws do
  def updated_files
    sync_dryrun_stdout = `aws s3 sync --dryrun #{OUTPUT_TSV_DIR}/ s3://#{S3_BUCKET_NAME}/tsv --include \"*tsv\"`
    sync_dryrun_stdout.split("\n").map{|line| File.basename(line.split("\s+").last) }
  end

  desc "Create update.txt and upload TSV files to AWS S3"
  task :update => [:create_list, :upload_s3]

  desc "Show updated files"
  task :show_updated do
    puts updated_files
  end

  desc "Create update.txt"
  task :create_list => [UPDATE_TXT]

  file UPDATE_TXT do
    puts "List of files to be updated at #{UPDATE_TXT}"
    open(UPDATE_TXT, 'w'){|f| f.puts(updated_files) }
  end

  desc "Upload TSV files to AWS S3"
  task :upload_s3 => UPDATE_TXT do
    puts "Uploading files to #{S3_BUCKET_NAME}..."
    system("aws s3 sync #{OUTPUT_TSV_DIR}/ s3://#{S3_BUCKET_NAME}/tsv --include \"*tsv\"")
    system("aws s3 cp #{UPDATE_TXT} s3://#{S3_BUCKET_NAME}/tsv/update.txt")
  end
end
