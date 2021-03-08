# RefSeq RNA -> Gene Symbol

### RefSeq について

NCBI の公開する RefSeq は、3つの molecule type に分かれている。

```
Molecule Type    Accession Prefix
----------------------------------------------
protein          NP_; XP_; AP_; YP_; WP_
rna              NM_; NR_; XM_; XR_
genomic          NC_; AC_; NG_; NT_; NW_; NZ_
```

上記の rna（以下、RefSeq RNA）のエントリから ID の対応表を作成する。  
RefSeq RNA には以下のエントリが含まれている。

```
NM_     mRNA        protein-coding transcripts          Prefix followed by 6 or 9 numbers,
                                                        followed by the sequence version number;
                                                        curated by NCBI staff or a model organism 
                                                        database; these records are referred to 
                                                        as the 'known' RefSeq dataset
                                                           
XM_     mRNA        protein-coding transcripts          Prefix followed by 6 or 9 numbers,
                                                        followed by the sequence version number; 
                                                        generated through either the eukaryotic 
                                                        genome annotation pipeline, or the small 
                                                        eukaryotic genome annotation pipeline; 
                                                        records generated via the first method are
                                                        referred to as the 'model' RefSeq dataset.
                                                        
NR_     RNA         non-protein-coding transcripts      Prefix followed by 6 or 9 numbers,
                    including lncRNAs, structural       followed by the sequence version number;
                    RNAs, transcribed pseudogenes,      curated by NCBI staff or a model organism
                    and transcripts with unlikely       database; these records are referred to as      
                    protein-coding potential from       the 'known' RefSeq dataset      
                    protein-coding genes

XR_     RNA         non-protein-coding transcripts,     Prefix followed by 6 or 9 numbers,      
                    as above                            followed by the sequence version number
                                                        generated through either the eukaryotic 
                                                        genome annotation pipeline, or the small
                                                        eukaryotic genome annotation pipeline; 
                                                        records generated via the first method are
                                                        referred to as the 'model' RefSeq dataset.
```

### ファイルの取得

**リリースファイル**  
ftp://ftp.ncbi.nlm.nih.gov/refseq/release/  
2ヶ月に1回リリースされる。2021年1月現在、release 204が最新。

**日々更新ファイル**  
ftp://ftp.ncbi.nlm.nih.gov/refseq/daily/  
リリース以降の日々更新ファイルがここに置かれる。

**生物種ごとのファイル**  
ftp://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/  
ヒトやマウスなど代表的な生物種については専用の置き場がある。  
更新は Weekly。今回はヒトのみを対象とするためここから取得する。

### ID 対応表の作成

一次情報である flat file (*.gbff) から各種 ID を抽出するスクリプトを作成した。

```
% gzip -dc human.*.rna.gbff.gz | ./parse_refseq_rna_gbff.pl --symbol
NM_001368885	COL13A1
NM_001368886	COL13A1
NR_148047	TACC1
NR_148053	TACC1
NM_001374457	SMARCA4
NR_148052	TACC1
NM_001354434	SMIM35
NR_104272	PGAP2
NR_137288	ARHGEF10L
NR_110936	DHFR
[...]
```

### Gene Symbol について

* ヒト以外の生物種の Gene Symbol は HGNC Symbol ではないため、本来は別の namespace や prefix が必要。
* ヒトの場合は、Gene Symbol にはほとんどの場合 HGNC Symbol が記載されている。
* HGNC Symbol が付与されていないエントリにも何らかの値が記載されている。（例：LOC123456）
* 以上をふまえてとりあえず `ncbigene_symbol` としている。

### メモ

* ~~ヒトの flat file (human.*.rna.gbff.gz) は合計 2.4 GB もあるので他の対応表でも使いまわしたい。~~  
→ 共通入力ファイル置き場 (input/) の利用により解決！
* wgetが他と重複実行されないよう排他ロックをかけている。`bin/setlock.rb` を利用。
  * [setlock の ruby 版](https://github.com/okaxaki/setlock) で、どの環境でも動作して使い勝手も良い。
  * `setlock.rb (ロックファイル) (コマンド)` で、ロックされている場合は解除を待って実行してくれる。
  * ロックファイルの有無ではなくロック状態で判定しているので終了後にロックファイルが残っていてよい。
