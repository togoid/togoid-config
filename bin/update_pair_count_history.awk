BEGIN {
    "date +%F" | getline date
    FS = "\t"
}

FNR==NR {
    gsub(".tsv","",$1)
    a[$1]=$2
    b[$1]=1
    next
}

FNR==1 {
    n=NF
    for(i=1; i<=NF; i++) {
	col[i]=$i
	printf $i
	delete b[$i]
	if(i!=NF) {
	    printf "\t"
	}
    }
    for(k in b) {
	printf "\t" k
	col[++n]=k
    }
    printf "\n"
    next
}

{
    for(i=1; i<=n; i++) {
	printf $i
	if(i!=n) {
	    printf "\t"
	}
    }
    printf "\n"
}

END {
    printf date
    for(i=2; i<=n; i++) {
	printf "\t" a[col[i]]
    }
}
