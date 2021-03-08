# RefSeq protein -> UniProtKB

### RefSeq protein について

NCBI の公開する RefSeq は、3つの molecule type に分かれている。

```
Molecule Type    Accession Prefix
----------------------------------------------
protein          NP_; XP_; AP_; YP_; WP_
rna              NM_; NR_; XM_; XR_
genomic          NC_; AC_; NG_; NT_; NW_; NZ_
```

上記の protein（以下、RefSeq protein）のエントリと UniProtKB の対応表を作成する。  

RefSeq protein のエントリには対応が記載されていないが、NCBI が対応表を公開しているのでそれを利用することにする。

ftp://ftp.ncbi.nlm.nih.gov/refseq/uniprotkb/gene_refseq_uniprotkb_collab.gz

上記ファイルの説明：

```
===========================================================================
gene_refseq_uniprotkb_collab            recalculated every month
---------------------------------------------------------------------------
           report of the relationship between NCBI Reference Sequence
           protein accessions and UniProtKB protein accessions

           tab-delimited
           one line per pair
           Column header line is the first line in the file.


           NOTE: these relationships are based on the following:
           1. identical sequence and tax_id
           2. identical tax_id, common protein_id
              (i.e. both sources cite the same source sequence)
           3. comparable tax_id, common protein_id 
              (RefSeq and UniProtKB may differ about the node 
               in NCBI's taxonomy tree to which the sequence is assigned,
               e.g. at the isolate or species level)

NCBI protein accession:
           the protein accession of the RefSeq

UniProtKB protein accession:
           the corresponding UniProtKB protein accession
```

### メモ

* ~~accession のみで version 情報がない (例: NP_123456)。ちなみに refseq_rna -> refseq_protein の対応のほうには accession.version (例: NP_123456.7) が記載されている。version を補うか？（がんばればできる）~~  
→ TogoID では、RefSeq RNA `refseq_rna` および RefSeq protein `refseq_protein` の version は記載しないことにする（ゲノムは残す方針）。
* ヒト以外の全生物種を含むのでサイズが大きい (約4600万行、約1GB)。
  * ヒトのみ抽出するか？（がんばればできる）
