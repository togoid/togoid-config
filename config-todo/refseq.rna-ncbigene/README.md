# RefSeq RNA -> NCBI Gene ID

### RefSeq について

NCBI の公開する RefSeq は、3つの molecule type に分かれている。

```
Molecule Type    Accession Prefix
----------------------------------------------
protein          NP_; XP_; AP_; YP_; WP_
rna              NM_; NR_; XM_; XR_
genomic          NC_; AC_; NG_; NT_; NW_; NZ_
```

上記の `rna` （以下、RefSeq RNA）のエントリから ID の対応表を作成する。  
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
更新は weekly。今回はヒトのみを対象とするためここから取得する。

### ID 対応表の作成

一次情報である flat file (*.gbff) から各種 ID を抽出するスクリプトを作成した。

```
% gzip -dc human.*.rna.gbff.gz | ./parse_refseq_rna_gbff.pl --geneid
NM_001368885.1	1305
NM_001368886.1	1305
NR_158981.1	9910
NR_148048.2	6867
NR_148047.2	6867
NR_148053.2	6867
NM_001374457.1	6597
NR_148052.2	6867
NM_001354434.2	100526771
NR_104272.2	27315
[...]
```

### NCBI Gene ID について

* 特記事項なし

### 課題

* ヒトの flat file (human.*.rna.gbff.gz) は合計 2.4 GB もあるので他の対応表でも使いまわしたい。
* refseq.rna の名称はとりあえず RefSeq の分類に合わせた。refseq.transcript とするかは検討事項。
* config.yaml の記載事項をレビューしてほしい。
