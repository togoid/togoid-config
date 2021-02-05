# coding: utf-8

import csv
import json
import re
from SPARQLWrapper import SPARQLWrapper

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

    ?fromdb linkdb_core:dblabel "compound" .
    ?todb   linkdb_core:dblabel "chebi" .

    ?from rdfs:label ?fromlabel .
    ?to   rdfs:label ?tolabel .
} ORDER BY ?fromlabel ?tolabel
'''

# 実行
kegg_sparql = SPARQLWrapper(endpoint=KEGG_Endpoint, returnFormat='json')
kegg_sparql.setQuery(query)
results = kegg_sparql.query().convert()['results']['bindings']



with open('pairs.tsv', 'w') as f:
    # for r in results[:100]:  # 全部
    for r in results[:100]:  # サンプル100個
        print(r['fromlabel']['value'].replace('cpd:',''),r['tolabel']['value'].replace('chebi:','CHEBI:'),sep='\t',file=f)
