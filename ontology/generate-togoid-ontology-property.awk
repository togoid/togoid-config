### 

function to_snake(s) {
    return gensub(" ", "_", "g", tolower(s))
}

BEGIN {
    FS = "\t"
    print "@prefix : <http://togoid.dbcls.jp/ontology/> ."
    print "@prefix owl: <http://www.w3.org/2002/07/owl#> ."
    print "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> ."
    print ""
}

{
    print ":" to_snake($1)
    print "    a owl:ObjectProperty ;"
    if ($5!="-")
        print "    rdfs:domain :" gensub(", ", ", :", "g", $5) " ;"
    if ($8!="-")
        print "    rdfs:range :" gensub(", ", ", :", "g", $8) " ;"
    if ($11=="TRUE")
        print "    owl:inverseOf :" to_snake($10) " ;"
    print "    rdfs:label \"" $1 "\" .\n"
}

