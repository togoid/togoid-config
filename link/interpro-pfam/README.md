# interpro-*

- `/tmp/togoid/` ディレクトリ内で ftp://ftp.ebi.ac.uk/pub/databases/interpro/interpro.xml.gz をダウンロードしパース、InterPro ID に対する全ての関係を `ipr_all_pairs.tsv` として出力。  
`interpro.xml.gz` が最新である場合(`/tmp/togoid/interpro.xml.gz` とダウンロード元のファイルサイズが一致する場合)はここは省略される。  

- 各ディレクトリ内に、`ipr_all_pairs.tsv` から必要な関係を抽出し `pair.tsv` として出力

- なお、`interpro-go` はダウンロード元のファイルが異なるので別
