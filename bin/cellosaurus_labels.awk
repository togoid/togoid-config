### 

BEGIN {
    RS = "\n//\n";
    FS = "\n"
    if (!label_filename || !synonym_filename) {
        print "usage: awk -v label_filename=<FILENAME> -v synonym_filename=<FILENAME> -f cellosaurus_labels.awk" > "/dev/stderr"
        exit
    }
}

{
    label = ""
    taxons = ""
    n = 0
    for (i=1; i<=NF; i++) {
        ## AC   CVCL_0030
        if ($i ~ /^AC/) {
            ac = substr($i, 11)
        }
        ## ID   HeLa
        else if ($i ~ /^ID/) {
            label = substr($i, 6)
        }
        ## OX   NCBI_TaxID=9606; ! Homo sapiens (Human)
        else if ($i ~ /^OX/) {
            match($i, /;/)
            taxon = substr($i, 17, RSTART-17)
            if(taxons)
                taxons = taxons "|" taxon
            else
                taxons = taxon
        }
        ## SY   HELA; Hela; He La; He-La; HeLa-CCL2; Henrietta Lacks cells; Helacyton gartleri
        else if ($i ~ /^SY/) {
            split(substr($i, 6), synonyms, "; ")
        }
    }
    print label "\t" ac "\t" taxons > label_filename
    for (k in synonyms)
        print synonyms[k] "\t" ac "\t" taxons > synonym_filename
}
