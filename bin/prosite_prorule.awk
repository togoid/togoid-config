BEGIN { 
    RS="//\n"; 
    FS="\n"; 
    ac = ""; 
    pr = ""; 
    OFS="\t"; 
}

{
    for (i=1; i<=NF; i++) {
        if ($i ~ /^AC/) {
            split($i, ac_arr, "   ");
            ac = ac_arr[2];
            gsub(/;$/, "", ac);  # 行末のセミコロンを削除
        }
        if ($i ~ /^PR/) {
            split($i, pr_arr, "   ");
            split(pr_arr[2], pr_ids, ";");  # セミコロンで複数のIDを区切る
            for (j=1; j<=length(pr_ids); j++) {
                gsub(/^ +| +$/, "", pr_ids[j]);  # 余分な空白を削除
                if (ac && pr_ids[j]) {
                    print ac, pr_ids[j];
                }
            }
            ac = ""; 
        }
    }
}
