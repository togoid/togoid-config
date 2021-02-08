# interpro-*

- `interpro-pfam` ディレクトリ内で ftp://ftp.ebi.ac.uk/pub/databases/interpro/interpro.xml.gz をダウンロードしパース、InterPro ID に対する全ての関係を `ipr_all_pairs.tsv` として出力。  
`interpro-pfam/ipr_all_pairs.tsv` が既に存在する場合はここは省略される。  
`interpro-pfam/ipr_all_pairs.tsv` が最新であることは現状担保していない。全ての `interpro-*` ディレクトリ内の `pair.tsv` が最新になっていたら `interpro-pfam/ipr_all_pairs.tsv` を削除もしくはリネームするなどで対応できるが、運用上 `pair.tsv` をどのように管理するか次第。

- 各ディレクトリ内に、`ipr_all_pairs.tsv` から必要な関係を抽出し `pair.tsv` として出力

- なお、`interpro-go` はダウンロード元のファイルが異なるので別
