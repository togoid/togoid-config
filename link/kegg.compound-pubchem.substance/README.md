# KEGG Compound -> Pubchem
* kegg_linkdb.py:
  GenomeNetのエンドポイントにSPQRQLクエリをかけます
```
usage: kegg_linkdb.py [-h] [-n N] [--filename FILENAME] fromdb todb

positional arguments:
  fromdb               変換元DB
  todb                 変換先DB

optional arguments:
  -h, --help           show this help message and exit
  -n N                 サンプルの数。0：全部
  --filename FILENAME  出力ファイル名
```

* pairs.tsv
