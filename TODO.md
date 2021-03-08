# config-todo

* ChEBI や GO や DOID などの prefix が表記ゆれ激しい
* ファイルを取ってきているようなものは RDF 化してから ID 抽出するほうが良さそう
* 時間のかかる SPARQL を分割して投げる場合のジョブコントロールをどうするか
* link の predicate が rdfs:seeAlso のママのものが半数

* config/db.1-db.2 を config/db_1-db_2 にする or config/db-1_db-2 にする？
  * → MySQL のテーブル名で . が使えないことを避けるための変更なので、同じく使えない - ではなく _ にすべき
  * → config/db_1-db_2 で

## affy.hg.u133.plus.2-ncbigene/

* affy.hg.u133.plus.2 なのか affy.probeset なのか affymetrix なのか
  * → affy_probeset で
* sparql_csv2tsv.sh でよさげ

## chembl-chembl.target/

* 守屋スレッドで get-taxonomy-list と get-id-list の SPARQL を投げるパターン

## chembl-uniprot/

* 同上

## chembl.target-ensembl.ensg/

* sparql_csv2tsv.sh でよさげ
* pair.tsv が長すぎ

## chembl.target-go/

* sparql_csv2tsv.sh でよさげ
* pair.tsv が長すぎ
* GO: は必要？

## chembl.target-intact/

* sparql_csv2tsv.sh でよさげ
* pair.tsv が長すぎ

## chembl.target-interpro/

* sparql_csv2tsv.sh でよさげ
* pair.tsv が長すぎ

## chembl.target-pdb/

* sparql_csv2tsv.sh でよさげ
* pair.tsv が長すぎ

## chembl.target-pfam/

* sparql_csv2tsv.sh でよさげ
* pair.tsv が長すぎ

## chembl.target-reactome.pathway/

* sparql_csv2tsv.sh でよさげ
* pair.tsv が長すぎ

## civic-ensembl.transcript/

* sparql_csv2tsv.sh でよさげ

## civic-ncbigene/

* sparql_csv2tsv.sh でよさげ

## dgidb-chembl/

* sparql_csv2tsv.sh でよさげ
* pair.tsv が長すぎ
* DGIDB の ID は b44c2fe3-bc5e-452f-9194-d8e64b7dfd28 とか使う？

## dgidb-ncbigene/

* sparql_csv2tsv.sh でよさげ
* pair.tsv が長すぎ
* DGIDB の ID は b44c2fe3-bc5e-452f-9194-d8e64b7dfd28 とか使う？

## dgidb-pubmed/

* sparql_csv2tsv.sh でよさげ
* pair.tsv が長すぎ
* DGIDB の ID は b44c2fe3-bc5e-452f-9194-d8e64b7dfd28 とか使う？

## doid-kegg.pathway/

* README 不要
* sparql_csv2tsv.sh で URI prefix と \w+: を削る
* pair.tsv が長すぎ
* DOID: と KEGG: を削る

## doid-mesh/

* README 不要
* sparql_csv2tsv.sh で URI prefix と \w+: を削る
* pair.tsv が長すぎ
* DOID: と MESH: を削る
* nodeID://b6070057 など bnode が入っている

## doid-omim/

* 同上

## ensembl-affy.hg.u133.plus.2/

* Mart に wget で XML クエリを投げているパターン
* pair.tsv が長すぎ
* target ID が無い行がある
* source を ensembl.gene に変更

```
ENSG00000210117	1553538_s_at
ENSG00000210117	1553569_at
ENSG00000210117	1553570_x_at
ENSG00000210127	
ENSG00000210135	
```

* README より

- Ensembl Biomart のRESTを使って、Ensembl GeneID をキーに各社のマイクロアレイIDを取れそう
- とりあえず、affy.hg.u133.plus.2 をやってみた例です
- Biomart 出力に対して　uniqueRows=1
- Ensembl ID に対して複数のAffyIDがつく
- Ensembl ID に対して、どのAffyIDも対応しない行がある(こういうのは削除したほうが良いですか?)

## ensembl-ensembl.protein/

* Ruby で taxonomy ID ごとに２つ目の SPARQL クエリを投げているパターン
* source を ensembl.gene に変更

## ensembl-ensembl.transcript/

* Ruby で taxonomy ID ごとに２つ目の SPARQL クエリを投げているパターン
* source を ensembl.gene に変更

## ensembl-hgnc/

* sparql_csv2tsv.sh でよさげ
* ただし text/csv ではなく text/tab-separated-values を受け取っている（エンドポイント依存）
* tail -n +2 | tr -d '"'
* わざわざ echo で pair.tsv にコマンドラインを出力しないでくれ…
* source を ensembl.gene に変更

## ensembl-omim/

* 同上
* source を ensembl.gene に変更

## ensembl-refseq/

* Ruby で taxonomy ID ごとに２つ目の SPARQL クエリを投げているパターン
* link.tsv がちょっと長い
* source を ensembl.gene に変更

## ensembl.protein-ensembl.transcript/

* Ruby で taxonomy ID ごとに２つ目の SPARQL クエリを投げているパターン

## ensembl.transcript-hgnc/

* Ruby で taxonomy ID ごとに２つ目の SPARQL クエリを投げているパターン

## go-intact/

* sparql_csv2tsv.sh で URI prefix と \w+: を削る
* ID の prefix 要確認

```
GO_0019907	EBI-1246076
GO_0019907	EBI-9868598
GO_0034066	EBI-9517136
```

## go-interpro/

* 取得プログラムなし
* README より

- 今回はInterProとのペアを取りたいのだが、InterProのリンクは<owl:Axiom>の中（ということで要検討）
- そもそもEndpointに入っているよね。。。

## go-kegg.reaction/

* sparql_csv2tsv.sh で URI prefix と \w+: を削る
* pair.tsv が長い

```
GO_0004039	R00005
GO_0003834	R00032
GO_0003951	R00104
```

* README より

- とりあえず、ペアをとるためのSPARQLは書いた。
- 更新スクリプト（curl 〜みたいな感じか）までは行き着けず。とりあえずアップしておく。

## go-pubmed/

* 取得プログラムなし
* README より

```
- 今回はPubMedとのペアを取りたいのだが、PubMedのリンクは<owl:Axiom>の中（ということで要検討）
- 他のものは（owl:Class内にリンクがある場合は）次のようなSPARQLを書けるが (sparql.rq)、これを https://integbio.jp/rdf/sparql に投げるとなぜか16件は返ってくる
```

## go-reactome/

* 取得プログラムなし
* README より

- とりあえず、ペアをとるためのSPARQLは書いた。
- 更新スクリプト（curl 〜みたいな感じか）までは行き着けず。とりあえずアップしておく。


## go-rhea/

* sparql_csv2tsv.sh で URI prefix と \w+: を削る
* pair.tsv が長い

```
GO_0003961	10051
GO_0000016	10079
GO_0004122	10115
```

## hgnc-ccds/

* sparql_csv2tsv.sh でよさげ

## hgnc-ena/

* sparql_csv2tsv.sh でよさげ

## hgnc-ensembl/

* sparql_csv2tsv.sh でよさげ

## hgnc-ensembl.transcript/

* sparql_csv2tsv.sh でよさげ

## hgnc-insdc/

* sparql_csv2tsv.sh でよさげ

## hgnc-lrg/

* sparql_csv2tsv.sh でよさげ

## hgnc-mgi/

* sparql_csv2tsv.sh でよさげ
* MGI: は削る

## hgnc-mirbase/

* sparql_csv2tsv.sh でよさげ

## hgnc-ncbigene/

* sparql_csv2tsv.sh でよさげ

## hgnc-omim/

* sparql_csv2tsv.sh でよさげ

## hgnc-orphanet/

* sparql_csv2tsv.sh でよさげ

## hgnc-pubmed/

* sparql_csv2tsv.sh でよさげ

## hgnc-refseq/

* sparql_csv2tsv.sh でよさげ

## hgnc-rgd/

* sparql_csv2tsv.sh でよさげ

## hgnc-uniprot/

* sparql_csv2tsv.sh でよさげ

## hint-pubmed/

* sparql_csv2tsv.sh でよさげ
* pair.tsv と sample.tsv
* IDペアが source になっているが良いか（使い物になるか）？

```
Q8NER1-Q8NER1	11358970
Q8NEU8-Q9Y230	19433865
Q8NEZ2-Q9NZ09	22405001
```

## hint-uniprot/

* sparql_csv2tsv.sh でよさげ
* pair.tsv と sample.tsv
* IDペアが source になっているが良いか（使い物になるか）？

```
A0A024QYV7-A0A024QYV7	A0A024QYV7
A0A024QYV7-A0A024QYV7	A0A024QYV7
A0A024QYV7-B4DEE8	A0A024QYV7
```

## homologene-ncbigene/

* NCBI の FTP サイトから TSV を curl で取ってきて cut しているパターン

## human.protein.atlas-ensembl/

* sparql_csv2tsv.sh でよさげ

## instruct-pdb/

* sparql_csv2tsv.sh でよさげ
* link.tsv と sample.tsv
* instructのIDはこれでよいか（使い物になるか）？

```
A1L0T0-PF00205_A1L0T0-PF00205	1mcz
A1L0T0-PF00205_A1L0T0-PF00205	1upc
A1L0T0-PF00205_A1L0T0-PF00205	2vjy
```

## instruct-pfam/

* 同上

## instruct-pubmed/

* 同上

## instruct-uniprot/

* 同上

## interpro-go/

* EBI から interpro2go を curl でダウンロードして awk 処理するパターン

```
IPR000003	GO_0003677
IPR000003	GO_0003707
IPR000003	GO_0008270
```

## interpro-pdb/

* EBI から interpro.xml.gz を curl でダウンロードして Python で処理するパターン

* README より

- `/tmp/togoid/` ディレクトリ内で ftp://ftp.ebi.ac.uk/pub/databases/interpro/interpro.xml.gz をダウンロードしパース、InterPro ID に対する全ての関係を `ipr_all_pairs.tsv` として出力。  
`interpro.xml.gz` が最新である場合(`/tmp/togoid/interpro.xml.gz` とダウンロード元のファイルサイズが一致する場合)はここは省略される。  
- 各ディレクトリ内に、`ipr_all_pairs.tsv` から必要な関係を抽出し `pair.tsv` として出力
- なお、`interpro-go` はダウンロード元のファイルが異なるので別

## interpro-pfam/

* 同上
* pair.tsv が短い

## interpro-pubmed/

* 同上

## interpro-reactome/

* 同上
* pair.tsv が長い

## mbgd.gene-uniprot/

* sparql_csv2tsv.sh でよさげ
* pair.tsv と sample.tsv
* mbgd側のIDが汚い

```
hsa:HSA_10047086	B3KTV8
hsa:HSA_10047086	I6S2Y9
hsa:HSA_10047086	Q9UJM3
```

## mbgd.organism-ncbi.taxonomy/

* method に SPARQL への短縮 URL が書かれている…
* sparql_csv2tsv.sh でよさげ
* pair.tsv が長い

## medgen-ncbigene/

* sparql_csv2tsv.sh でよさげ

## mondo-doid/

* sparql_csv2tsv.sh でよさげ
* ID の prefix はこれでいいの？

```
MONDO_0005570	DOID_74
MONDO_0004471	DOID_813
MONDO_0004472	DOID_8130
```

## mondo-hp/

* sparql_csv2tsv.sh で URI prefix と \w+: を削る
* mondo-hp.sh と mondo-hp.bash
* link.tsv が長い
* README 不要
* prefix 不要

```
MONDO:0019540	HP:0025420
MONDO:0004568	HP:0002590
MONDO:0004585	HP:0001561
```

## mondo-meddra/

* sparql_csv2tsv.sh でよさげ

## mondo-mesh/

* sparql_csv2tsv.sh でよさげ

## mondo-omim/

* sparql_csv2tsv.sh でよさげ

## mondo-orphanet/

* sparql_csv2tsv.sh でよさげ

## nando-kegg.disease/

* sparql_csv2tsv.sh でよさげ

## nando-mondo/

* sparql_csv2tsv.sh でよさげ
* nando の prefix

## oma.protein-ensembl/

* sparql_csv2tsv.sh でよさげ
* pair.tsv が長い

## oma.protein-ensembl.transcript/

* 同上

## oma.protein-uniprot/

* 同上

## ordo-hgnc/

* sparql_csv2tsv.sh でよさげ
* config.yaml の : 前後のスペースをきれいに
* method には ordo-hgnc.bash と書かれているが .sh でしょう
* pair.tsv が長い
* ORPHA: と HGNC: は削る
* README 不要

## ordo-mesh/

* 同上

## ordo-omim/

* 同上

## ordo-uniprot/

* 同上

## pdb-ec/

* 守屋スレッドで get-taxonomy-list と get-id-list の SPARQL を投げるパターン
* config.yaml の : 前後のスペースをきれいに

## pdb-go/

* 守屋スレッドで get-taxonomy-list と get-id-list の SPARQL を投げるパターン
* pair.tsv で GO: を削除

```
1G0M	GO:0003796
6BG3	GO:0003796
6BG5	GO:0003796
```

## pdb-interpro/

* 守屋スレッドで get-taxonomy-list と get-id-list の SPARQL を投げるパターン

## pdb-pfam/

* 守屋スレッドで get-taxonomy-list と get-id-list の SPARQL を投げるパターン

## pdb-uniprot/

* 守屋スレッドで get-taxonomy-list と get-id-list の SPARQL を投げるパターン

## reactome-go/

* sparql_csv2tsv.sh でよさげ
* GO の prefix は？

```
R-CEL-975634	GO_0001523
R-CEL-2142789	GO_0006744
R-CEL-389542	GO_0006740
```

## reactome-reactome.reaction/

* sparql_csv2tsv.sh でよさげ

## reactome.reaction-chebi/

* sparql_csv2tsv.sh でよさげ

## reactome.reaction-uniprot/

* sparql_csv2tsv.sh でよさげ

## refseq.rna-dbsnp/

* NCBI の FTP から RefSeq の gbff をダウンロードして内藤さんの Perl でパースするパターン
* BioPerl や BioRuby を車輪の再発明している感じある。。
* 下記の refseq-* の数ほどフラットファイルを０からスキャンするのはもったいないし、RefSeq を RDF に変換するのは https://github.com/dbcls/rdfsummit/tree/master/insdc2ttl や TogoWS でできるので、gbff を取ってきて RDF 化してエンドポイントに入れて sparql_csv2tsv.sh で検索するだけでいいのでは？

## refseq.rna-hgnc/

* 同上

## refseq.rna-mim/

* 同上

## refseq.rna-ncbigene/

* 同上

## refseq.rna-pubmed/

* 同上

## refseq.rna-refseq.protein/

* 同上

## refseq.rna-symbol/

* 同上

## refseq.rna-taxonomy/

* 同上

## rhea-chebi/

* sparql_csv2tsv.sh でよさげ

## rhea-ec/

* sparql_csv2tsv.sh でよさげ
* echo でコマンドラインを出力しないで

## rhea-kegg.reaction/

* sparql_csv2tsv.sh で URI prefix を削る

## rhea-reactome/

* sparql_csv2tsv.sh でよさげ

## sra.accession-bioproject/

* NCBI の FTP から curl で取ってきた /tmp/togoid/SRA_Accessions.tab を読み込んで awk でわけのわからないことをやるパターン
* 取得部分と抽出部分を切り分けるべき
* 元データがただのタブ切りなのでサクッと RDF 化してクエリで取得するようにするのがスジがよさそう

## sra.accession-biosample/

* 同上

## sra.accession-sra.analysis/

* 同上

## sra.accession-sra.experiment/

* 同上

## sra.accession-sra.project/

* 同上

## sra.accession-sra.run/

* 同上

## sra.accession-sra.sample/

* 同上

## sra.experiment-bioproject/

* 同上

## sra.experiment-biosample/

* 同上

## sra.experiment-sra.project/

* 同上

## sra.experiment-sra.sample/

* 同上

## sra.project-bioproject/

* 同上

## sra.run-bioproject/

* 同上

## sra.run-biosample/

* 同上

## sra.run-sra.experiment/

* 同上

## sra.run-sra.project/

* 同上

## sra.run-sra.sample/

* 同上

## sra.sample-biosample/

* 同上

## togovar-clinvar/

* sparql_csv2tsv.sh でよさげ

## togovar-dbsnp/

* sparql_csv2tsv.sh でよさげ

## togovar-ensembl/

* TogoVar から tsv をダウンロードしてきているだけ（これはどうなのか？）

## togovar-ensembl.transcript/

* 同上

## togovar-hgnc/

* 同上

## togovar-medgen/

* 同上

## togovar-ncbigene/

* 同上

## togovar-pubmed/

* 同上

## togovar-refseq.mRNA/

* 同上

## uniprot-chembl.target/

* 守屋スレッドで get-taxonomy-list と get-id-list の SPARQL を投げるパターン

## uniprot-dbsnp/

* 同上

## uniprot-drugbank/

* 同上

## uniprot-ec/

* 同上

## uniprot-ensembl/

* 同上

## uniprot-ensembl.protein/

* 同上

## uniprot-ensembl.transcript/

* 同上

## uniprot-go/

* 同上

## uniprot-hgnc/

* 同上

## uniprot-intact/

* 同上

## uniprot-interpro/

* 同上

## uniprot-kegg.genes/

* 同上

## uniprot-ncbigene/

* 同上

## uniprot-ncbiprotein/

* 同上

## uniprot-oma/

* 同上

## uniprot-omim/

* 同上

## uniprot-orphanet/

* 同上

## uniprot-pdb/

* 同上

## uniprot-pfam/

* 同上

## uniprot-reactome/

* 同上

## uniprot-refseq/

* 同上

## wikipathways-chebi/

* sparql_csv2tsv.sh で URI prefix を削る

## wikipathways-doid/

* sparql_csv2tsv.sh で URI prefix を削る

```
WP1266_r106847	DOID_9007
WP1_r107192	DOID_1287
WP202_r95798	DOID_114
```

## wikipathways-uniprot/

* sparql_csv2tsv.sh で URI prefix を削る

# insdc2ttl

* git commit
* fix variant URI, faldo:position

