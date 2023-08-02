import xml.sax
import sys

class XMLHandler(xml.sax.ContentHandler):
    def __init__(self, target_tags):
        self.target_tags = target_tags
        self.current_attrs = {}
        self.current_tag = ""
        self.current_depth = 0

    def init_current_attrs(self):
        for tag in self.target_tags:
            self.current_attrs[tag] = ""

    def startElement(self, tag, attrs):
        self.current_tag = tag
        self.current_depth += 1
        #print("depth:", self.current_depth)
        #print("begin tag:", tag)
        if tag == "metabolite":
            self.init_current_attrs()

    def characters(self, content):
        #print("text:", content)
        if self.current_tag in self.target_tags and self.current_depth == 3:
            # The `characters` method may split strings at a random position.
            # Concatenating a content rather than simply assigning (i.e. using `+=` rather than `=`) can avoid the issue.
            # cf. https://bytes.com/topic/python/answers/447239-xml-sax-parser-bug
            self.current_attrs[self.current_tag] += content

    def endElement(self, tag):
        #print("end tag:", tag)
        if tag == "metabolite":
            for target_tag in self.target_tags:
                xref_id = self.current_attrs[target_tag]
                if target_tag != "accession" and len(xref_id) > 0:
                    print(self.current_attrs["accession"], target_tag,
                          xref_id, sep="\t")
        self.current_tag = ""
        self.current_depth -= 1


def extract_text_to_tsv(xml_file, target_tags):
    handler = XMLHandler(target_tags)
    parser = xml.sax.make_parser()
    parser.setContentHandler(handler)
    parser.parse(xml_file)


target_tags = ["accession", "name", "inchikey", "drugbank_id", "pdb_id", "pubchem_compound_id", "chebi_id"]
ns = "{http://www.hmdb.ca}"
input_xml = sys.argv[1]
extract_text_to_tsv(input_xml, target_tags)
