# TogoID ver. 2.0
Datasets last updated: 2024-12-17

## About
- [TogoID](https://togoid.dbcls.jp/) は、直感的なインターフェースにより生命科学系データベース(DB)間のつながりを探索的に確認しながらID変換を行うことができるウェブアプリケーションです。同一の実体を指すID間の変換だけでなく、関連する別のカテゴリーのIDへの変換も可能です。また、直接リンクされていないDBのID間でも、他のDBを経由した変換を探索することができます。
- 各オリジナルDBからIDの対応関係を取得するプログラムをデータセットのペアごとに作成し、これを用いて毎週の定期更新を行っています。プログラムは[GitHub レポジトリ](https://github.com/dbcls/togoid-config/)で公開しており、誰でも自由に参照できるとともに、新規データセットペアの追加等の提案をすることもできます。
- ID間の対応関係が持つ生物学的意味についての語彙集([オントロジー](https://togoid.dbcls.jp/ontology))を整備し、それらをウェブインターフェース上で参照できるようにすることで探索的なID変換を実現しています。
- TogoIDに収載されているデータセットの詳細については、"DATASETS"タブからご覧いただけます。

## 動画マニュアル
- [TogoIDを使って生命科学系データベースのさまざまなIDを探索的に変換する](https://youtu.be/gXnvm6Fn4R8)

## 統計 (2024-12-17)
- 対象データセット数 
    - 105 (73 のデータベースに由来)
- 対象DBの詳細やID例については、"DATASETS" タブ からご覧いただけます。 

一つのデータベースが複数の概念を取り扱っている場合、TogoID では概念ごとに「データセット」としてそのデータベースのレコードを分割して扱うことで、ID が指すものの曖昧性を排除しています。例えば、Ensembl データベースは Ensembl gene, Ensembl transcript, Ensembl protein の 3 つのデータセットとして扱っています。

## Web user interface

### EXPLORE
EXPLORE タブでは、入力した ID を他のデータセットの ID に変換し、その変換された ID をさらに他のデータセットの ID に変換するというマルチステップな ID 変換を探索的に行うことができます。
![Fig-1A](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig1A.jpg)
1. ID の入力欄。ID リストを直接ペーストするか、テキストファイルをアップロードすることができます。各 ID は、改行、コンマ、スペースのいずれかで区切られている必要があります。

2. 入力した ID が属するデータセットの候補。右の数字は、入力 ID のうちそのデータセットの ID の正規表現にマッチするものの数。

3. 入力 ID から直接リンクされているデータセット。左の数字は、入力 ID のうちそのデータセットの ID に 1 つ以上変換できるものの数。右の数字は、変換の結果得られるそのデータセットの ID のユニークな数。

4. データセット間の関係。[TogoID ontology](https://togoid.dbcls.jp/ontology) にて定義されています。

5. 最初の変換先として選択されたデータセットからリンクされているデータセット。

6. マウスオーバーした際に表示されるメニュー。左のテーブルアイコンは Results ウィンドウ(後述)を表示。中央のダウンロードアイコンは、変換された ID のリストをダウンロードするショートカット。右の i アイコンはデータセットの詳細を表示。

### NAVIGATE
NAVIGATE タブでは、変換元と変換先のデータセットを指定することで、両者をつなぐデータセットのパスの候補を調べ、指定したパスで ID 変換を行うことができます。
![Fig-1B](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig1B.jpg)
![Fig-1C](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig1C.jpg)

7. 入力 ID の属するデータセットの候補。

8. 変換のゴールを選択するためのプルダウンメニュー。文字を入力して絞り込めます。

9. 入力とターゲットをつなぐ変換パス。入力からターゲットに至るまで、最大 2 つのデータセットを経由するパスが表示されます。

### Results ウインドウ
EXPLORE もしくは NAVIGATE タブで、テーブルアイコンをクリックしたときに表示されるモーダルウインドウでは、変換結果のテーブルを最大 100 行プレビューできます。テーブルの形式を選択したうえで、結果の全体をダウンロードしたりクリップボードにコピーしたりできます。
![Fig-1D](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig1D.jpg)
10. Report  
- All converted IDs: 変換された ID を、経由したデータセットの ID も含めて表示します。
- Source and target IDs: 入力とターゲットの ID のみを表示します。
- Target IDs: ターゲットの ID のみを表示します。
- All including unconverted IDs: ターゲットに変換されなかった入力 ID もテーブルに含めます。変換先 ID の列の当該行は空白になります。

11. Format  
- Expanded: デフォルトのモード。正規化されたテーブルが表示されます。
- Compact: 複数の ID が前のステップの 1 つの ID にリンクされている場合、変換された ID は一行にスペース区切りでまとめて表示されます。

12. Action  
Preview に表示されている形式で、結果の全体をダウンロードしたり、クリップボードにコピーしたりできます。  
Copy API URL では、現在表示している形式の変換結果をダウンロードするための API の URL がクリップボードにコピーされます。  
Copy CURL では、UNIX の curl コマンドで POST メソッドを利用して API を使用し、現在表示している形式の変換結果をダウンロードするコマンドがクリップボードにコピーされます。

13. Show Labels
オンにすると、ID に対応するラベルが表示されます。一部データセットは、技術的理由あるいはオリジナルデータベースの利用規約のため未対応です。  

14. ID 記法に複数のパターンがある場合、このプルダウンメニューでパターンを指定できます。例えば Gene Ontology の ID では、プレフィックスが "GO:" の場合と "GO_" の場合があるので、ここで必要に応じて変更できます。また、オリジナルデータベースにおける各エントリーの URL を表示することもできます。

![Fig-1E](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig1E.jpg)
15. ID の変換を行わずに、入力 ID のラベルの取得だけを行いたい場合、入力した ID に該当するデータセットにマウスオーバーし、テーブルアイコンをクリックします。
16. 開いたモーダルウインドウで、Show labels をクリックし、ラベルを表示します。

### LABEL2ID
LABEL2ID タブでは、ラベルを ID に変換できます。例えば、遺伝子シンボルを NCBI Gene ID に変換したり、疾患名を MONDO ID に変換したりできます。  

#### 遺伝子シンボルを NCBI Gene ID に変換する場合

![Fig-2A](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig2A.jpg)

1. ラベルの入力欄。ラベルにはスペースが含まれることもあるため、ラベルの区切り文字は改行のみが許されています。

2. データセットを選択するプルダウンリスト。

3. 生物種を選択するプルダウンリスト。同一の遺伝子シンボルが複数の生物種で使われていることがあるため、マップするべき ID を特定するために生物種の指定が必須です。プルダウンリストには主要な生物種しか含まれていないので、目的のものが見つからない場合は Taxonomy ID を右の入力窓に直接入力してください。

4. 対象とするラベルのタイプの選択肢。シノニムを対象に含めたいかどうかを選択できます。

5. 条件を選択後、EXECUTE ボタンをクリックします。

![Fig-2B](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig2B.jpg)

6. 変換結果のテーブル。
- Input: 入力した ID
- Match type: どのタイプのラベルにマッチしたか。
- Symbol: 該当する ID のメインシンボル。
- ID: 変換結果として得られた ID

7. Convert IDs をクリックすると、変換の結果得られた ID を、EXPLORE モードでの変換に移行させることができます。

#### 疾患名を MONDO ID に変換する場合
疾患名などは、表記揺れを許した変換が可能です。

![Fig-2C](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig2C.jpg)

8. ラベルのマッチにおいて許容する曖昧性のスコアの閾値。0.5 から 1 の間で設定でき、1 だと完全一致のみが許され、値が小さくなるほど寛容なマッチが許容されます。

![Fig-2D](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig2D.jpg)

9. 結果のテーブルでは、マッチのスコアが表示されます。

### DATASETS
TogoID が対象としているデータセットの詳細を閲覧できます。
![Fig-3A](https://raw.githubusercontent.com/dbcls/togoid-config/production/docs/img/TogoID_Original_Fig3A.jpg)
1. データセットのカテゴリーで絞り込めます。
2. データセットからリンクされているデータセット。右の数字は総ペア数を示します。データセット名をクリックするとこのタブの当該データセットの項目に移動します。
3. ID 例。入力可能な ID パターンも示しています。HP phenotype では "HP:" と "HP_" というプレフィックスのパターンが使えることを示しています。クリックすると ID 入力欄に入力され、変換を試すことができます。

## API
ウェブインターフェイスだけでなく、APIも用意しており、他のアプリケーションからのID変換にも利用することができます。  
利用方法の詳細は [API Documentation (Swagger)](https://togoid.dbcls.jp/apidoc/) をご覧ください。  
以下は、NCBI Gene ID を UniProt ID 経由で PDB ID に変換した結果を取得する例です。  
1. [変換できなかった ID も含めて json で取得する](https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,uniprot,pdb&format=json&report=full)
2. [入力とターゲットの対応関係を tsv で取得する](https://api.togoid.dbcls.jp/convert?ids=5460,6657,9314,4609&route=ncbigene,uniprot,pdb&format=tsv&report=pair)

また、LABEL2ID の機能には [PubDictionaries](https://pubdictionaries.org/) を利用しています。[TogoID で用いている辞書](https://pubdictionaries.org/users/togoid) は公開されているので、PubDictionaries の API を使用してアクセスすることができます。  
例: [シノニムを含めてヒトの遺伝子シンボルを検索し NCBI Gene ID に変換する](https://pubdictionaries.org/find_ids.json?labels=ACE2%7CHIF2A&dictionaries=togoid_ncbigene_symbol,togoid_ncbigene_synonym&tags=9606&threshold=1&verbose=true)

## 論文
- Shuya Ikeda, Hiromasa Ono, Tazro Ohta, Hirokazu Chiba, Yuki Naito, Yuki Moriya, Shuichi Kawashima, Yasunori Yamamoto, Shinobu Okamoto, Susumu Goto, Toshiaki Katayama, TogoID: an exploratory ID converter to bridge biological datasets, _Bioinformatics_, 2022;, btac491, [https://doi.org/10.1093/bioinformatics/btac491](https://doi.org/10.1093/bioinformatics/btac491)

## 紹介PDF･記事
- [TogoID: データベース統合の基盤となるID変換サービス](https://biosciencedbc.jp/event/symposium/togo2021/files/poster03_togo2021.pdf)
    - 2021年10月トーゴーの日シンポジウムにて[発表](https://biosciencedbc.jp/event/symposium/togo2021/poster/003.html)
- [TogoID：生命科学系データベースのさまざまなIDを探索的に変換できるウェブアプリケーション](https://doi.org/10.18958/7013-00005-0000134-00)
    - 実験医学2022年5月号　クローズアップ実験法
    - DOI [10.18958/7013-00005-0000134-00](https://doi.org/10.18958/7013-00005-0000134-00)
