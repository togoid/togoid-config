### DrugBankの利用について
DrugBankのダウンロードデータのライセンスはCC BY-NC であるため、Togoサイトでの利用は難しいです。

### make_pairs.pyのロジック

- 主ID

xmlデータ内の全ての`<drug>` `<drugbank-id>`ノードを取得し、内部テキストがDBから始まるIDを取得する。

- 対応ID

xmlデータ内の全ての`<drug>` `<general-references>` `<articles>` `<article>` `<pubmed-id>`ノードを取得する。1つの主IDに対して複数ある場合あり。

