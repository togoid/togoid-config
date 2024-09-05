BEGIN {
    if(!prefix) {
        print("usage: awk -v prefix=DB_PREFIX -f parse_vcv_phenotype.awk FILE") > "/dev/stderr"
        exit(1)
    }
    regex = "^" prefix
    FS = "\t"
    OFS = "\t"
}

FNR>=2 {
    vcv = $31
    n = split($13, phenos_for_rcv, "|")
    for (i=1; i<=n; i++) {
        split(phenos_for_rcv[i], phenos_for_condition, ";")
        for (k in phenos_for_condition) {
            split(phenos_for_condition[k], phenos, ",")
            for (l in phenos) {
                if(phenos[l]~regex && !a[phenos[l], vcv]++)
                    print(vcv, gensub(regex, "", "g", phenos[l]))
            }
        }
    }
}
