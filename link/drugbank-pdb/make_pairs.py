import csv
import re
from xml.etree import ElementTree


NAMESPACE = '{http://www.drugbank.ca}'
drugbank = ElementTree.parse('all-full-database.xml').getroot()

def id(drug):
    for dbid in drug.findall('./{0}drugbank-id'.format(NAMESPACE)):
        if re.match(r'DB\d+', dbid.text) is not None: return dbid.text 
    assert False

with open('pair.tsv', 'w', newline='') as file:
    tsv = csv.writer(file, delimiter='\t')
    for drug in drugbank.findall('./'):
        id1 = id(drug)
        for entry in drug.findall('./{0}pdb-entries/{0}pdb-entry'.format(NAMESPACE)):
            row = [id1, entry.text]
            tsv.writerow(row)
