#! /usr/bin/gawk -f

function snake2camel(s,
                     n, words, camel, i) {
    n = split(s, words, "_")
    camel = ""
    for(i=1; i<=n; i++)
        camel = camel toupper(substr(words[i], 1, 1)) substr(words[i], 2)
    return camel
}

BEGIN {
    if (ARGC != 4) {
        print "usage: generate-togoid-ontology.awk <class table> <dataset table> <property table>" > "/dev/stderr"
        exit 0
    }
    FS = "\t"
    print "@prefix : <http://togoid.dbcls.jp/ontology#> ."
    print "@prefix owl: <http://www.w3.org/2002/07/owl#> ."
    print "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> ."
    print "@prefix dcterms: <http://purl.org/dc/terms/> ."
    print "@prefix skos: <http://www.w3.org/2004/02/skos/core#> ."
    print ""
    print ": a owl:Ontology ."
    print ""
    print ":Category"
    print "    a owl:Class ;"
    print "    rdfs:label \"Category\" ."
    print ""
    print ":Dataset"
    print "    a owl:Class ;"
    print "    rdfs:label \"Dataset\" ."
    print ""
    print ":relation"
    print "    a owl:ObjectProperty ;"
    print "    rdfs:comment \"Identifiers of the domain dataset have a biological relation with that of the range dataset.\" ."
    print ""
    print ":display_label"
    print "    a owl:DatatypeProperty ;"
    print "    rdfs:comment \"A label to be displayed on the TogoID web UI.\" ."
    print ""
}

FNR==1 {
    fn++
}

fn==1 {
    print ":" $1
    print "    a owl:Class ;"
    print "    rdfs:label \"" $2 "\" ;"
    printf "    rdfs:subClassOf :Category"
    if ($3) {
        printf " , :" gensub(", ", " , :", "g", $3)
    }
    print " .\n"
    next
}

fn==2 {
    print ":" snake2camel($1)
    print "    a owl:Class ;"
    print "    dcterms:identifier \"" $1 "\" ;"
    print "    rdfs:label \"" $2 "\" ;"
    print "    rdfs:subClassOf :" gensub(", ", " , :", "g", $3) ", :Dataset .\n"
}

fn==3 {
    print ":" $1
    print "    rdfs:subPropertyOf :relation ;"
    if ($5 != "-") {
        print "    rdfs:domain :" gensub(", ", ", :", "g", $5) " ;"
    }
    if ($6 != "-")
        print "    rdfs:range :" gensub(", ", ", :", "g", $6) " ;"
    if ($4 != $1)
        print "    owl:inverseOf :" $4 " ;"
    print "    rdfs:label \"" $2 "\" ;"
    print "    :display_label \"" $3 "\" .\n"
}

