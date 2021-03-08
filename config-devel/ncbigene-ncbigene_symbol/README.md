# NCBI Gene ID -> Gene Symbol

### NCBI Gene について

NCBI Gene の gene_info ファイルから対応表を作成する。

ftp.ncbi.nlm.nih.gov/gene/DATA/GENE_INFO/All_Data.gene_info.gz

上記ファイルの説明：

```
===========================================================================
gene_info                                       recalculated daily
---------------------------------------------------------------------------
           tab-delimited
           one line per GeneID
           Column header line is the first line in the file.
           Note: subsets of gene_info are available in the DATA/GENE_INFO
                 directory (described later)
           This file is identical in content to GENE_INFO/All_Data.gene_info.gz
                 even though their file sizes and timestamps may differ
                 slightly
---------------------------------------------------------------------------

tax_id:
           the unique identifier provided by NCBI Taxonomy
           for the species or strain/isolate

GeneID:
           the unique identifier for a gene
           ASN1:  geneid

Symbol:
           the default symbol for the gene
           ASN1:  gene->locus
[...]
```

### メモ

* 全生物種で 31,045,086 行
* ヒトに限ると 61,734 行
* 収録されている生物種 31,709 種
