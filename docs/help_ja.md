# TogoID ver. 1.1
Datasets last updated: 2024-06-18

## About
- [TogoID](https://togoid.dbcls.jp/) は、直感的なインターフェースにより生命科学系データベース(DB)間のつながりを探索的に確認しながらID変換を行うことができるウェブアプリケーションです。同一の実体を指すID間の変換だけでなく、関連する別のカテゴリーのIDへの変換も可能です。また、直接リンクされていないDBのID間でも、他のDBを経由した変換を探索することができます。
- 各オリジナルDBからIDの対応関係を取得するプログラムをデータセットのペアごとに作成し、これを用いて毎週の定期更新を行っています。プログラムは[GitHub レポジトリ](https://github.com/dbcls/togoid-config/)で公開しており、誰でも自由に参照できるとともに、新規データセットペアの追加等の提案をすることもできます。
- ID間の対応関係が持つ生物学的意味についての語彙集([オントロジー](https://togoid.dbcls.jp/ontology))を整備し、それらをウェブインターフェース上で参照できるようにすることで探索的なID変換を実現しています。
- TogoIDに収載されているデータセットの詳細については、"DATASETS"タブからご覧いただけます。

## 動画マニュアル
- [TogoIDを使って生命科学系データベースのさまざまなIDを探索的に変換する](https://youtu.be/gXnvm6Fn4R8)

## 論文
- Shuya Ikeda, Hiromasa Ono, Tazro Ohta, Hirokazu Chiba, Yuki Naito, Yuki Moriya, Shuichi Kawashima, Yasunori Yamamoto, Shinobu Okamoto, Susumu Goto, Toshiaki Katayama, TogoID: an exploratory ID converter to bridge biological datasets, _Bioinformatics_, 2022;, btac491, [https://doi.org/10.1093/bioinformatics/btac491](https://doi.org/10.1093/bioinformatics/btac491)

## 紹介PDF･記事
- [TogoID: データベース統合の基盤となるID変換サービス](https://biosciencedbc.jp/event/symposium/togo2021/files/poster03_togo2021.pdf)
    - 2021年10月トーゴーの日シンポジウムにて[発表](https://biosciencedbc.jp/event/symposium/togo2021/poster/003.html)   
- [TogoID：生命科学系データベースのさまざまなIDを探索的に変換できるウェブアプリケーション](https://doi.org/10.18958/7013-00005-0000134-00)
    - 実験医学2022年5月号　クローズアップ実験法 
    - DOI [10.18958/7013-00005-0000134-00](https://doi.org/10.18958/7013-00005-0000134-00)

## API
- ウェブインターフェイスだけでなく、APIも用意しており、他のアプリケーションからのID変換にも利用することができます。
    1. [https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,ensembl_gene&format=json](https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,ensembl_gene&format=json)
    2. [https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,ensembl_gene,uniprot&format=json](https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,ensembl_gene,uniprot&format=json)
    3. [https://api.togoid.dbcls.jp/convert?format=json&report=pair&route=pubchem_compound,chebi,reactome_reaction,uniprot,ncbigene&ids=649](https://api.togoid.dbcls.jp/convert?format=json&report=pair&route=pubchem_compound,chebi,reactome_reaction,uniprot,ncbigene&ids=649)

- [API Documentation (Swagger)](https://togoid.dbcls.jp/apidoc/)

## 統計 (2024-06-18)
- 対象データセット数 
    - 104 (72のデータベースに由来)
- 対象DBの詳細やID例については、"DATASETS" タブ からご覧いただけます。 

## Web user interface

### ID conversion in the "EXPLORE" mode.

![Fig-1A](https://raw.githubusercontent.com/dbcls/togoid-config/main/docs/img/TogoID_Original_Fig1A.jpg)

### ID conversion in the "NAVIGATE" mode.

![Fig-1B](https://raw.githubusercontent.com/dbcls/togoid-config/main/docs/img/TogoID_Original_Fig1B.jpg)

### Browsing available datasets.

![Fig-2A](https://raw.githubusercontent.com/dbcls/togoid-config/main/docs/img/TogoID_Original_Fig2A.jpg)

### Conversion results.

![Fig-2B](https://raw.githubusercontent.com/dbcls/togoid-config/main/docs/img/TogoID_Original_Fig2B.jpg)
