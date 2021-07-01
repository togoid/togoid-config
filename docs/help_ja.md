# TogoID

[TogoID](https://togoid.dbcls.jp/) は、生命科学分野のデータベース(DB)のID間のリンクを検索、変換することができるWebアプリケーションです。

## About
- IDのリスト（数千件まで）を入力すると、変換候補のDBがリストアップされ、対応するIDに変換することができます。1対1のID変換だけでなく、変換先のDBに至る経路を含めて変換することも可能です。

- TogoIDでは、変換されたIDをさまざまな形式で取得する機能を提供しています。
    1. クリップボードにコピーして他のサービスですぐに使えるようにする
    2. 変換されたIDの一覧をテキスト形式で取得する
    3. オリジナルDBへのリンクURLを含む形式で変換されたIDの一覧を取得する
    4. 変換経路をすべて含む変換されたIDの一覧をCSV形式で取得する

- ID間のリンクは、各DBのRDFデータ、API、フラットファイルからの抽出によって整備しており、それらはGitHubの[togoid-config](https://github.com/dbcls/togoid-config/) レポジトリで管理･公開しています。対象DBのIDに関するメタデータや、IDペアの更新方法、更新頻度などを管理することで、常に最新のID間リンクを得られるようにしています。

## API
- ウェブインターフェイスだけでなく、APIも用意しており、他のアプリケーションからのID変換にも利用することができます。
    1. https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,ensembl_gene&format=json
    2. https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,ensembl_gene,uniprot&format=json
    3. https://api.togoid.dbcls.jp/convert?format=json&include=pair&route=pubchem_compound,chebi,reactome_reaction,uniprot,ncbigene&ids=649

- Swagger

## 統計 (2021年7月現在)
- 対象DB数 
    - 62
- IDペア数
    - 154
- 対象DBの詳細やID例については、DATABASES タブ からご覧いただけます。 

## Web user interface

* Copy target IDs

* Download target IDs

* Download target URLs

* Download table as CSV
