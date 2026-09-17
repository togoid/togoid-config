#!/bin/bash
# Compute an updated log/pair_count.tsv and an updated last line of
# log/pair_count_history.tsv for a subset of tsv files that were
# re-generated after a partial re-run, without recounting every file.
# Results are written to new, dated files; the originals are left untouched.
#
# Usage: bin/update_pair_count_partial.sh output/tsv/foo.tsv output/tsv/bar.tsv ...

set -euo pipefail

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <tsv file> [<tsv file> ...]" >&2
    exit 1
fi

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd "$script_dir/.." && pwd)
pair_count="$repo_root/log/pair_count.tsv"
pair_count_history="$repo_root/log/pair_count_history.tsv"
date=$(date +%F)
pair_count_out="$repo_root/log/pair_count-$date.tsv"
pair_count_history_out="$repo_root/log/pair_count_history-$date.tsv"

tmp_counts=$(mktemp)
tmp_pair_count=$(mktemp)
tmp_history=$(mktemp)
trap 'rm -f "$tmp_counts" "$tmp_pair_count" "$tmp_history"' EXIT

for f in "$@"; do
    name=$(basename "$f")
    count=$(wc -l < "$f")
    printf '%s\t%s\n' "$name" "$count" >> "$tmp_counts"
done

echo "New line counts:"
cat "$tmp_counts"

awk -F'\t' -v OFS='\t' '
FNR==NR { newcount[$1] = $2; next }
{
    if ($1 in newcount) {
        delta = newcount[$1] - $2
        $2 = newcount[$1]
        $4 = $2 - $3
        $5 = ($3 != "") ? $2 / $3 : ""
        total_delta += delta
        matched[$1] = 1
    }
    if ($1 == "total") {
        $2 = $2 + total_delta
        $4 = $2 - $3
        $5 = $2 / $3
    }
    print
}
END {
    for (name in newcount) {
        if (!(name in matched)) {
            print "error: " name " not found in pair_count.tsv" > "/dev/stderr"
            exit 1
        }
    }
}
' "$tmp_counts" "$pair_count" > "$tmp_pair_count"

new_total=$(awk -F'\t' '$1=="total"{print $2}' "$tmp_pair_count")

awk -F'\t' -v OFS='\t' -v new_total="$new_total" '
FNR==NR { newcount[$1] = $2; next }
FNR==1 { for (i = 1; i <= NF; i++) colidx[$i] = i }
{ lines[FNR] = $0; last = FNR }
END {
    n = split(lines[last], f, "\t")
    for (name in newcount) {
        key = name
        gsub(/\.tsv$/, "", key)
        if (key in colidx) {
            f[colidx[key]] = newcount[name]
        } else {
            print "warning: no history column for " key > "/dev/stderr"
        }
    }
    if ("total" in colidx) {
        f[colidx["total"]] = new_total
    }
    for (l = 1; l < last; l++) {
        print lines[l]
    }
    out = f[1]
    for (i = 2; i <= n; i++) {
        out = out OFS f[i]
    }
    print out
}
' "$tmp_counts" "$pair_count_history" > "$tmp_history"

mv "$tmp_pair_count" "$pair_count_out"
mv "$tmp_history" "$pair_count_history_out"

echo "Wrote $pair_count_out"
echo "Wrote $pair_count_history_out"
echo "(originals left untouched: $pair_count, $pair_count_history)"
