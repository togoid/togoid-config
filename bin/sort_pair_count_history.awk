### 

BEGIN {
    OFS = "\t"
    FS = "\t"
}

FNR==1 {
    for(i=1; i<=NF; i++) {
        colnames[i] = $i
        colnames_inv[$i] = i
        if ($i == "total")
            total_col_num = i
    }
    asort(colnames, sorted_colnames)

    order[1] = 1
    n = 2
    for(i=2; i<=NF; i++) {
        if(sorted_colnames[i] != "total") {
            order[n] = colnames_inv[sorted_colnames[i]]
            n++
        }
    }
    order[n] = total_col_num
}

{
    for(i=1; i<=NF; i++) {
        if (i == NF)
            printf $(order[i]) "\n"
        else
            printf $(order[i]) "\t"
    }
}
