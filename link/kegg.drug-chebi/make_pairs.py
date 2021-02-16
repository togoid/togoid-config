# coding: utf-8

import csv
import json
import re
import argparse
from SPARQLWrapper import SPARQLWrapper

# 出力ファイル名とサンプル数を引数にする
parser = argparse.ArgumentParser()
parser.add_argument('-n', type=int, default=0, help='サンプルの数。0：全部')
parser.add_argument('--filename',  default='pairs.tsv', help='出力ファイル名')
args = parser.parse_args()
filename=args.filename
n=args.n
# エンドポイント
KEGG_Endpoint='https://www.genome.jp/sparql/linkdb'


# クエリ
query='''
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX linkdb: <https://www.genome.jp/linkdb/>
PREFIX linkdb_core: <https://www.genome.jp/linkdb/core/>
SELECT ?fromlabel ?tolabel WHERE {
    ?from linkdb:equivalent ?to .
    ?from linkdb_core:database ?fromdb .
    ?to   linkdb_core:database ?todb .

    ?fromdb linkdb_core:dblabel "drug" .
    ?todb   linkdb_core:dblabel "chebi" .

    ?from rdfs:label ?fromlabel .
    ?to   rdfs:label ?tolabel .
} ORDER BY ?fromlabel ?tolabel
'''

# 実行
kegg_sparql = SPARQLWrapper(endpoint=KEGG_Endpoint, returnFormat='json')
kegg_sparql.setQuery(query)
results = kegg_sparql.query().convert()['results']['bindings']

if n==0:
    n=len(results)


with open(filename, "w") as f:
    for r in results[:n]:
        print(r['fromlabel']['value'].replace('dr:',''), r['tolabel']['value'].replace('chebi:','CHEBI:'), sep='\t',file=f)
