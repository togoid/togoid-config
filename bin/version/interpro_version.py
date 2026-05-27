import xml.etree.ElementTree as ET
import sys

def parse_xml_stream(source):
    context = ET.iterparse(source, events=("end",))
    
    for event, elem in context:
        if elem.tag == "dbinfo":
            version = elem.get("version")
            name = elem.get("dbname")
            
            if name == "INTERPRO":
                print(version)
                return
            
            elem.clear()
        
        elif elem.tag == "release":
            elem.clear()
            return

def main():
    try:
        parse_xml_stream(sys.stdin)
    except EOFError:
        pass
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)

if __name__ == "__main__":
    main()