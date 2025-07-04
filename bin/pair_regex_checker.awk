### 

BEGIN {
    if (ARGC <= 2) {
        print "usage: awk -f pair_regex_checker.awk path/to/dataset.yaml [path/to/tsv_files]" > "/dev/stderr"
        exit 1
    }
    system("date")
    if (!limit)
        limit = 10
}

## dataset.yaml
FNR==NR {
    if ($0~/^[^ ]+: *$/) {
        namespace = gensub(/: */, "", "g", $1)
    }
    if ($0~/ +regex:/) {
        regex[namespace] = gensub(/(^ *regex: *'\^)|(\$'$)|(\?<id[0-9]*>)/, "", "g", $0)
    }
    if ($0~/ +prefix:/) {
        prefix[namespace] = gensub(/(^ *prefix: *'.+\/)|('$)/, "", "g", $0)
    }
    next
}

## source-target.tsv
### Since regexps in dataset.yaml are written in Perl, awk cannot directly determine whether each line matches the regexp. To circumvent this issue, this script calls `grep` with the `-P` option.
FNR==1 {
    split(gensub(/.*\//, "", "g", FILENAME), splitted_filename, "-")
    source = splitted_filename[1]
    target = gensub(/\.tsv$/, "", "g", splitted_filename[2])
    line_regex = "'^" regex[source] "\t" regex[target] "$'"
    print("awk -F '\t' '{print \"" prefix[source] "\" $1 \"\t\" \"" prefix[target] "\" $2}' " FILENAME " | grep -vP " line_regex " | head")
    system("awk -F '\t' '{print \"" prefix[source] "\" $1 \"\t\" \"" prefix[target] "\" $2}' " FILENAME " | grep -vP " line_regex " | head -" limit)
    nextfile
}

END {
    system("date")
}
