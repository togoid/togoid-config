#!/bin/sh
set -euo pipefail

# 2021/04/13時点で1946977件あるので、200万件を超えた場合は最後の行のコメントアウトを取る必要あり。

curl -sSH "Accept: text/tab-separated-values" --data-urlencode query="PREFIX sio: <http://semanticscience.org/resource/> SELECT (substr(str(?cid), 49) AS ?pubchem_id) ?chembl_id { SELECT DISTINCT ?cid (ucase(str(?chembl)) AS ?chembl_id) FROM <http://rdf.integbio.jp/dataset/pubchem> {[ sio:is-attribute-of ?cid ; a sio:CHEMINF_000412 ; sio:has-value ?chembl ] . } offset 0 limit 1000000 }" https://integbio.jp/rdf/pubchem/sparql | tail -n +2
curl -sSH "Accept: text/tab-separated-values" --data-urlencode query="PREFIX sio: <http://semanticscience.org/resource/> SELECT (substr(str(?cid), 49) AS ?pubchem_id) ?chembl_id { SELECT DISTINCT ?cid (ucase(str(?chembl)) AS ?chembl_id) FROM <http://rdf.integbio.jp/dataset/pubchem> {[ sio:is-attribute-of ?cid ; a sio:CHEMINF_000412 ; sio:has-value ?chembl ] . } offset 1000000 limit 1000000 }" https://integbio.jp/rdf/pubchem/sparql | tail -n +2
#curl -sSH "Accept: text/tab-separated-values" --data-urlencode query="PREFIX sio: <http://semanticscience.org/resource/> SELECT (substr(str(?cid), 49) AS ?pubchem_id) ?chembl_id { SELECT DISTINCT ?cid (ucase(str(?chembl)) AS ?chembl_id) FROM <http://rdf.integbio.jp/dataset/pubchem> {[ sio:is-attribute-of ?cid ; a sio:CHEMINF_000412 ; sio:has-value ?chembl ] . } offset 2000000 limit 1000000 }" https://integbio.jp/rdf/pubchem/sparql | tail -n +2 
