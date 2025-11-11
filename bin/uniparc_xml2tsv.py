import xml.sax
import sys

target_dbs = {"RefSeq", "PDB", "UniProtKB/Swiss-Prot protein isoforms"}

class XMLHandler(xml.sax.ContentHandler):
    def __init__(self):
        self.init_current_entry()
        self.tag_stack = []

    def init_current_entry(self):
        self.current_uniparc_id = ""
        self.current_content = ""

    def init_current_reference(self):
        self.current_content = ""
        self.current_reference_type = ""
        self.current_reference_id = ""
        self.current_reference_active = ""
        self.current_reference_version = ""
        self.current_reference_taxonomy = ""

    def startElement(self, tag, attrs):
        self.tag_stack.append(tag)

        if tag == "entry":
            self.init_current_entry()

        if self.tag_stack == ["uniparc", "entry", "dbReference"]:
            self.init_current_reference()
            self.current_reference_type = attrs.getValue("type")
            self.current_reference_id = attrs.getValue("id")
            self.current_reference_active = attrs.getValue("active")
            if attrs.__contains__("version"):
                self.current_reference_version = attrs.getValue("version")
        elif self.tag_stack == ["uniparc", "entry", "dbReference", "property"]:
            if attrs.getValue("type") == "NCBI_taxonomy_id":
                self.current_reference_taxonomy = attrs.getValue("value")


    def characters(self, content):
        self.current_content += content.strip()

    def endElement(self, tag):
        if self.tag_stack == ["uniparc", "entry", "accession"]:
            self.current_uniparc_id = self.current_content

        if self.tag_stack == ["uniparc", "entry", "dbReference"]:
            if self.current_reference_type in target_dbs:
                print(self.current_uniparc_id,
                      self.current_reference_type,
                      self.current_reference_id,
                      self.current_reference_version,
                      self.current_reference_active,
                      self.current_reference_taxonomy, sep="\t")

        self.tag_stack.pop()
        self.current_content = ""


def extract_text_to_tsv(xml_file):
    handler = XMLHandler()
    parser = xml.sax.make_parser()
    parser.setContentHandler(handler)
    parser.parse(xml_file)


if len(sys.argv) > 1:
    input_xml = sys.argv[1]
else:
    input_xml = sys.stdin

extract_text_to_tsv(input_xml)
