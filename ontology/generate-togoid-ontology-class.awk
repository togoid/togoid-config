### 

function snake2camel(s,
                     n, words, camel, i) {
    n = split(s, words, "_")
    camel = ""
    for(i=1; i<=n; i++)
        camel = camel toupper(substr(words[i], 1, 1)) substr(words[i], 2)
    return camel
}

BEGIN {
    FS = "\t"
    print "@prefix : <http://togoid.dbcls.jp/ontology/> ."
    print "@prefix owl: <http://www.w3.org/2002/07/owl#> ."
    print "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> ."
    print ""
    print ": a owl:Ontology .\n"
    print ":Category"
    print "    a owl:Class ;"
    print "    rdfs:label \"Category\" .\n"
}

!a[$2]++ {
    print ":" $2
    print "    a owl:Class ;"
    print "    rdfs:label \"" $2 "\" ;"
    print "    rdfs:subClassOf :Category .\n"
}

{
    print ":" snake2camel($1)
    print "    a owl:Class ;"
    print "    rdfs:label \"" $1 "\" ;"
    print "    rdfs:subClassOf :" $2 " .\n"
}

END {
    
}
