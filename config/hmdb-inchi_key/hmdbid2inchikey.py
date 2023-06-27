import xml.etree.ElementTree as ET
tree = ET.parse('hmdb_metabolites.xml')
root = tree.getroot()
f = open("hmdbid2inchikey.txt", "a")
for i in range(len(root)):
    if root[i][17].text == None:
        pass
    else:
        f.write(root[i][3].text + "\t" + root[i][17].text + "\n")
f.close()
