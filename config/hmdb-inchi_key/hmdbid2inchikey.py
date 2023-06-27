import xml.etree.ElementTree as ET
import sys

input_xml = sys.argv[1]
tree = ET.parse(input_xml)
root = tree.getroot()

for i in range(len(root)):
    if root[i][17].text == None:
        pass
    else:
        print(root[i][3].text + "\t" + root[i][17].text)
