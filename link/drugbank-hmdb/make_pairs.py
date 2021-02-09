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
    for exlink in drug.findall('./{0}general-references/{0}links/{0}link'.format(NAMESPACE)):
        ttl = exlink.find('./{0}title'.format(NAMESPACE))
        if ttl is None: return None
        if 'HMDB' == ttl.text[:4]:
            return re.search(r'/(HMDB[0-9A-Z]+)[^/]*$', exlink.find('./{0}url'.format(NAMESPACE)).text).group(1)
    return None

with open('pair.tsv', 'w', newline='') as file:
    tsv = csv.writer(file, delimiter='\t')
    for drug in drugbank.findall('./'):
        row = [id(drug), id2(drug)]
        if row[1] is not None: tsv.writerow(row)
