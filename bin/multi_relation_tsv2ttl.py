import csv
import os
import sys
import yaml

dataset_filepath = sys.argv[1]
with open(dataset_filepath, "r") as f:
    dataset = yaml.safe_load(f)

config_filepath = sys.argv[2]
with open(config_filepath, "r") as f:
    config = yaml.safe_load(f)
    config_dict = {}
    for relation in config:
        config_dict[relation["link"]["forward"]] = relation
    abs_path = os.path.abspath(f.name)
    dir_path = os.path.dirname(abs_path)
    dir_name = os.path.basename(dir_path)
    source = dir_name.split("-")[0]
    target = dir_name.split("-")[1]

print("@prefix\ttio:\t<http://togoid.dbcls.jp/ontology#>\t.")
print("@prefix\t", source, ":\t<", dataset[source]["prefix"], ">\t.", sep="")
print("@prefix\t", target, ":\t<", dataset[target]["prefix"], ">\t.", sep="")
print("")

for tsv_filepath in sys.argv[3:]:
    with open(tsv_filepath, "r") as f:
        reader = csv.reader(f, delimiter="\t")
        fwd = os.path.basename(tsv_filepath).split("-")[-1].split(".")[0]
        rev = config_dict[fwd]["link"]["reverse"]
        for line in reader:
            print(source, ":", line[0], "\ttio:", fwd, "\t", target, ":", line[1], "\t.", sep="")
            print(target, ":", line[1], "\ttio:", rev, "\t", source, ":", line[0], "\t.", sep="")

