import xml.sax
import sys
import re

class XMLHandler(xml.sax.ContentHandler):
    def __init__(self):
        self.init_current_package()
        self.tag_stack = []

    def init_current_package(self):
        self.current_bpid = ""
        self.current_id = ""  # internal ID
        self.current_title = ""
        self.current_xrefdb = ""
        self.current_content = ""
        self.current_pmids = []
        self.current_link_ref = ""
        self.current_hierarchical_type = ""
        self.current_umbrellas = []  # (member BioProject, umbrella BioProject)

    def startElement(self, tag, attrs):
        self.tag_stack.append(tag)

        if tag == "Package":
            self.init_current_package()
        if self.tag_stack == ["PackageSet", "Package", "Project", "Project", "ProjectID", "ArchiveID"]:
            self.current_bpid = attrs.getValue("accession")
            self.current_id = attrs.getValue("id")
        elif self.tag_stack == ["PackageSet", "Package", "Project", "Project", "ProjectDescr", "Publication"]:
            self.current_pmids.append(attrs.getValue("id"))
        elif self.tag_stack == ["PackageSet", "Package", "Project", "Project", "ProjectDescr", "ExternalLink", "dbXREF"]:
            self.current_xrefdb = attrs.getValue("db")
        elif self.tag_stack == ["PackageSet", "Package", "Project", "ProjectLinks", "Link", "ProjectIDRef"]:
            self.current_link_ref = attrs.getValue("accession")
        elif self.tag_stack == ["PackageSet", "Package", "Project", "ProjectLinks", "Link", "Hierarchical"]:
            self.current_hierarchical_type = attrs.getValue("type")
        elif self.tag_stack == ["PackageSet", "Package", "Project", "ProjectLinks", "Link", "Hierarchical", "MemberID"]:
            # In a TopAdmin link, MemberID is the umbrella project of the project in ProjectIDRef
            if self.current_hierarchical_type == "TopAdmin":
                self.current_umbrellas.append((self.current_link_ref, attrs.getValue("accession")))

    def characters(self, content):
        if self.tag_stack == ["PackageSet", "Package", "Project", "Project", "ProjectDescr", "Title"]:
            self.current_title += content
        elif self.tag_stack == ["PackageSet", "Package", "Project", "Project", "ProjectDescr", "ExternalLink", "dbXREF", "ID"]:
            self.current_content += content

    def endElement(self, tag):
        if self.tag_stack == ["PackageSet", "Package"]:
            print(self.current_bpid, "Title", self.current_title, sep="\t")
            print(self.current_bpid, "ID", self.current_id, sep="\t")
            for pmid in self.current_pmids:
                # ID might be PMC ID, DOI, etc. The type is not described in the xml.
                if re.match(r"^[0-9]+$", pmid):
                    print(self.current_bpid, "PubMed", pmid, sep="\t")
            for member, umbrella in self.current_umbrellas:
                print(member, "Umbrella", umbrella, sep="\t")
        elif self.tag_stack == ["PackageSet", "Package", "Project", "Project", "ProjectDescr", "ExternalLink", "dbXREF", "ID"]:
            if self.current_xrefdb == "GEO":
                print(self.current_bpid, "GEO", self.current_content, sep="\t")
        elif self.tag_stack == ["PackageSet", "Package", "Project", "ProjectLinks", "Link"]:
            self.current_link_ref = ""
            self.current_hierarchical_type = ""
        self.tag_stack.pop()
        self.current_content = ""


def extract_text_to_tsv(xml_file):
    handler = XMLHandler()
    parser = xml.sax.make_parser()
    parser.setContentHandler(handler)
    parser.parse(xml_file)


input_xml = sys.argv[1]
extract_text_to_tsv(input_xml)
