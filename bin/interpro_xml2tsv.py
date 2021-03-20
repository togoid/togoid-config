# Requires python3 (not work with python2)

import xml.etree.ElementTree as ET
import sys

def parse_xml(rootnode):
    for ipr_node in rootnode.findall("interpro"):
        ipr_id = ipr_node.attrib["id"]
        pub_list_node = ipr_node.find("pub_list")
        if pub_list_node is not None:
            for pub_node in pub_list_node:
                db_xref_node = pub_node.find("db_xref")
                if db_xref_node.attrib["db"] == "PUBMED":
                    print(ipr_id, "PUBMED", db_xref_node.attrib["dbkey"], sep="\t")
        for link_node_tag in ("member_list", "external_doc_list", "structure_db_links"):
            for link_node in ipr_node.findall(link_node_tag):
                for db_xref_node in link_node.findall("db_xref"):
                    print(ipr_id, db_xref_node.attrib["db"],
                          db_xref_node.attrib["dbkey"], sep="\t")
    return

def main():
    parse_xml(ET.fromstring(sys.stdin.read()))

if __name__ == "__main__":
    main()
