import xml.etree.ElementTree as ET
import sys

input_xml = sys.argv[1]
tree = ET.parse(input_xml)
root = tree.getroot()

attrs = ["inchikey", "drugbank_id", "pdb_id", "pubchem_compound_id", "chebi_id"]
ns = "{http://www.hmdb.ca}"

for i in range(len(root)):
    hmdb_id = root[i].findtext(ns+"accession")
    for attr in attrs:
        xref_id = root[i].findtext(ns+attr)
        if len(xref_id) > 0:
            print(hmdb_id, attr, xref_id, sep="\t")
