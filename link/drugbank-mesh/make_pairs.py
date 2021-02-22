import csv
import re
from xml.etree import ElementTree


NAMESPACE = '{http://www.drugbank.ca}'
drugbank = ElementTree.parse('all-full-database.xml').getroot()

def id(drug):
    for dbid in drug.findall('./{0}drugbank-id'.format(NAMESPACE)):
        if re.match(r'DB\d+', dbid.text) is not None: return dbid.text 
    assert False

def id2(drug):
    meshid = drug.find('./{0}categories/{0}category/{0}mesh-id'.format(NAMESPACE))
    if meshid is None: return None
    else: return meshid.text

with open('pair.tsv', 'w', newline='') as file:
    tsv = csv.writer(file, delimiter='\t')
    for drug in drugbank.findall('./'):
        row = [id(drug), id2(drug)]
        if row[1] is not None: tsv.writerow(row)
