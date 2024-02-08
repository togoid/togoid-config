import xml.sax
import sys
import re


class XMLHandler(xml.sax.ContentHandler):
    def __init__(self):
        self.init_current_sample()
        self.tag_stack = []

    def init_current_sample(self):
        self.current_bsid = ""
        self.current_geoid = ""
        self.current_geo_url = ""
        self.current_content = ""
        self.current_db = ""
        self.current_link_label = ""

    def startElement(self, tag, attrs):
        self.tag_stack.append(tag)

        if tag == "BioSample":
            self.init_current_sample()
        if self.tag_stack == ["BioSampleSet", "BioSample", "Ids", "Id"]:
            if attrs.__contains__("db"):
                self.current_db = attrs.getValue("db")
        elif self.tag_stack == ["BioSampleSet", "BioSample", "Links", "Link"]:
            if attrs.__contains__("label"):
                self.current_link_label = attrs.getValue("label")

    def characters(self, content):
        self.current_content += content.strip()

    def endElement(self, tag):
        if self.tag_stack == ["BioSampleSet", "BioSample", "Ids", "Id"]:
            if self.current_db == "BioSample":
                self.current_bsid = self.current_content
                self.current_db = ""
            elif self.current_db == "GEO":
                self.current_geoid = self.current_content
                self.current_db = ""
        elif self.tag_stack == ["BioSampleSet", "BioSample", "Links", "Link"]:
            if self.current_link_label == "GEO Web Link" or re.match(r'^GEO Sample', self.current_link_label):
                self.current_geo_url = self.current_content

        if self.tag_stack == ["BioSampleSet", "BioSample"]:
            if self.current_geoid != "":
                print(self.current_bsid, "GEO ID", self.current_geoid, sep="\t")
            if self.current_geo_url != "":
                print(self.current_bsid, "GEO URL", self.current_geo_url, sep="\t")

        self.tag_stack.pop()
        self.current_content = ""


def extract_text_to_tsv(xml_file):
    handler = XMLHandler()
    parser = xml.sax.make_parser()
    parser.setContentHandler(handler)
    parser.parse(xml_file)


input_xml = sys.argv[1]
extract_text_to_tsv(input_xml)
