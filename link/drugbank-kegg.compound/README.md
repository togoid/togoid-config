make_pairs.pyのロジック
主ID
xmlデータ内の全ての<drug><drugbank-id>ノードを取得し、内部テキストがDBから始まるIDを取得する。
対応ID
xmlデータ内の全ての
<drug><external-identifiers><external-identifier>ノードを取得し、それらのうち<resource>ノード内のテキストがKEGG Compoundであるものの<identifier>を取得する。
