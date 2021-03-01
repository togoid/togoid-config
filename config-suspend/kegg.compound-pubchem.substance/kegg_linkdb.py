# coding: utf-8

import csv
import json
import re
import argparse
from SPARQLWrapper import SPARQLWrapper

# 出力ファイル名とサンプル数を引数にする
parser = argparse.ArgumentParser()
parser.add_argument('fromdb',   help='変換元DB')
parser.add_argument('todb',   help='変換先DB')
parser.add_argument('-n', type=int, default=0, help='サンプルの数。0：全部')
parser.add_argument('--filename',  default='pairs.tsv', help='出力ファイル名')

args = parser.parse_args()
filename=args.filename
n=args.n
fromdb=args.fromdb
todb=args.todb
# エンドポイント
KEGG_Endpoint='https://www.genome.jp/sparql/linkdb'


# クエリのテンプレート
query_template='''
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX linkdb: <https://www.genome.jp/linkdb/>
PREFIX linkdb_core: <https://www.genome.jp/linkdb/core/>
SELECT ?fromlabel ?tolabel WHERE {{
    ?from linkdb:equivalent ?to .
    ?from linkdb_core:database ?fromdb .
    ?to   linkdb_core:database ?todb .

    ?fromdb linkdb_core:dblabel "{0}" .
    ?todb   linkdb_core:dblabel "{1}" .

    ?from rdfs:label ?fromlabel .
    ?to   rdfs:label ?tolabel .
}} ORDER BY ?fromlabel ?tolabel
'''

# 実行

query=query_template.format(fromdb,todb)
kegg_sparql = SPARQLWrapper(endpoint=KEGG_Endpoint, returnFormat='json')
kegg_sparql.setQuery(query)
results = kegg_sparql.query().convert()['results']['bindings']

if n==0:
    n=len(results)


with open(filename, "w") as f:
    for r in results[:n]:
        fromid=r['fromlabel']['value']
        toid=r['tolabel']['value']
        print(re.sub('[a-z]+:','',fromid), re.sub('[a-z]+:','',toid), sep='\t',file=f)
