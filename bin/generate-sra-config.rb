#!/usr/bin/env ruby
# Config generator for SRA/BioProject/BioSample ID relations
require 'yaml'
require 'fileutils'

module Accessions
  class GenerateConfig
    class << self
      @@config_dir_path = File.join(File.dirname($0), "..", "link")
      @@accession_tab_path = "ftp.ncbi.nlm.nih.gov/sra/reports/Metadata/SRA_Accessions.tab"

      def nodes
        {
          "sra_accession" => {
            "label" => "SRA Accessions",
            "type" => "DataSet",
            "namespace" => "sra_accession",
            "prefix" => "http://identifiers.org/insdc.sra/"
          },
          "sra_experiment" => {
            "label" => "SRA Experiment",
            "type" => "DataSet",
            "namespace" => "sra_experiment",
            "prefix" => "http://identifiers.org/insdc.sra/"
          },
          "sra_project" => {
            "label" => "SRA Project",
            "type" => "DataSet",
            "namespace" => "sra_project",
            "prefix" => "http://identifiers.org/insdc.sra/"
          },
          "sra_sample" => {
            "label" => "SRA Sample",
            "type" => "DataSet",
            "namespace" => "sra_sample",
            "prefix" => "http://identifiers.org/insdc.sra/"
          },
          "sra_run" => {
            "label" => "SRA Run",
            "type" => "DataSet",
            "namespace" => "sra_run",
            "prefix" => "http://identifiers.org/insdc.sra/"
          },
          "sra_analysis" => {
            "label" => "SRA Analysis",
            "type" => "DataSet",
            "namespace" => "sra_analysis",
            "prefix" => "http://identifiers.org/insdc.sra/"
          },
          "bioproject" => {
            "label" => "BioProject",
            "type" => "DataSet",
            "namespace" => "bioproject",
            "prefix" => "http://identifiers.org/bioproject/"
          },
          "biosample" => {
            "label" => "BioSample",
            "type" => "DataSet",
            "namespace" => "biosample",
            "prefix" => "http://identifiers.org/biosample/"
          },
        }
      end

      def nodes_links
        [
          {
            from: "sra_accession",
            to: "sra_project",
            method: parse_accession_tab("RP", 2, 1),
          },
          {
            from: "sra_accession",
            to: "sra_experiment",
            method: parse_accession_tab("RX", 2, 1),
          },
          {
            from: "sra_accession",
            to: "sra_sample",
            method: parse_accession_tab("RS", 2, 1),
          },
          {
            from: "sra_accession",
            to: "sra_run",
            method: parse_accession_tab("RR", 2, 1),
          },
          {
            from: "sra_accession",
            to: "sra_analysis",
            method: parse_accession_tab("RZ", 2, 1),
          },
          {
            from: "sra_accession",
            to: "biosample",
            method: parse_accession_tab("RS", 2, 18),
          },
          {
            from: "sra_accession",
            to: "bioproject",
            method: parse_accession_tab("RP", 2, 19),
          },
          {
            from: "sra_experiment",
            to: "sra_sample",
            method: parse_accession_tab("RX", 1, 12),
          },
          {
            from: "sra_experiment",
            to: "sra_project",
            method: parse_accession_tab("RX", 1, 13),
          },
          {
            from: "sra_experiment",
            to: "biosample",
            method: parse_accession_tab("RX", 1, 18),
          },
          {
            from: "sra_experiment",
            to: "bioproject",
            method: parse_accession_tab("RX", 1, 19),
          },
          {
            from: "sra_run",
            to: "sra_experiment",
            method: parse_accession_tab("RR", 1, 11),
          },
          {
            from: "sra_run",
            to: "sra_sample",
            method: parse_accession_tab("RR", 1, 12),
          },
          {
            from: "sra_run",
            to: "sra_project",
            method: parse_accession_tab("RR", 1, 13),
          },
          {
            from: "sra_run",
            to: "biosample",
            method: parse_accession_tab("RR", 1, 18),
          },
          {
            from: "sra_run",
            to: "bioproject",
            method: parse_accession_tab("RR", 1, 19),
          },
          {
            from: "sra_project",
            to: "bioproject",
            method: parse_accession_tab("RP", 1, 19),
          },
          {
            from: "sra_sample",
            to: "biosample",
            method: parse_accession_tab("RS", 1, 18),
          },
        ]
      end

      def parse_accession_tab(prefix, col_from, col_to)
        fname = File.basename(@@accession_tab_path)
        tmpf = "/tmp/togoid/#{fname}"
        "awk 'BEGIN{ FS=OFS=\"\t\" } $1 ~ /^.#{prefix}/ { print $#{col_from}, $#{col_to} }' \"${TOGOID_ROOT}/input/sra/SRA_Accessions.tab\" | grep -v '-'"
      end

      def link_attribute
        {
          "label" => "seeAlso",
          "namespace" => "rdfs",
          "prefix" => "http://www.w3.org/2000/01/rdf-schema#",
          "predicate" => "seeAlso",
        }
      end

      def generate
        iterate(:generate)
      end

      def generate_test
        iterate(:generate_test)
      end

      def remove
        iterate(:remove)
      end

      def iterate(command)
        nodes_links.each do |link|
          s_id = link[:from]
          t_id = link[:to]
          pair_id = "#{s_id}-#{t_id}"

          case command
          when :generate
            generate_config(pair_id, s_id, nodes[s_id], t_id, nodes[t_id], link[:method])
          when :remove
            remove_dirs(pair_id)
          end
        end
      end

      def generate_config(pair_id, s_id, s_attrs, t_id, t_attrs, method)
        data = {
          "link" => {
            "file" => "sample.tsv",
            "forward" => link_attribute,
            "reverse" => link_attribute,
          },
          "update" => {
            "frequency" => "Daily",
            "method" => "#{method}",
          }
        }
        create(pair_id, data)
      end

      def create(pair_id, data)
        config_filepath = File.join(@@config_dir_path, pair_id, "config.yaml")
        FileUtils.mkdir_p(File.dirname(config_filepath))
        open(config_filepath, "w"){|f| f.puts(YAML.dump(data).sub(/^---\n/,"")) }
      end

      def remove_dirs(pair_id)
        FileUtils.rm_rf(File.join(@@config_dir_path, pair_id))
      end
    end
  end
end

if __FILE__ == $0
  case ARGV[0]
  when "--rm"
    Accessions::GenerateConfig.remove
  else
    Accessions::GenerateConfig.generate
  end
end
