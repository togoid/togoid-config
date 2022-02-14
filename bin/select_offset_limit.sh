#!/bin/bash

QUERY=$1
ENDPOINT=$2

# 結果を格納する一時ファイル作成
TMPFILE=`mktemp /tmp/tmp-select_offset_limit.XXXXXX`

# 変数初期化
LIMIT=100000
offset=0
num_results=0
VERBOSE=0 # VERBOSE=1の時、LIMIT件ずつ時間を表示

# LIMIT件ずつ出力する
while :
do 

  if [ $VERBOSE -eq 1 ]; then echo $offset `date` >&2 ; fi

  # SELECT実行する
  cat $QUERY | echo $(cat) "OFFSET $offset LIMIT $LIMIT" | curl -s -H "Accept: text/csv" --data-urlencode "query@-" "$ENDPOINT" | sed -E 1d | perl -pe 's/,/\t/g; s/\"//g' >> $TMPFILE  

  # 件数をカウントする
  this_num_results=`wc -l $TMPFILE | awk '{print $1}'`

  # 次のループを回すか判定する 
  if [ $this_num_results -eq $num_results ] ; then break; fi

  offset=$(( $offset+$LIMIT )) 
  num_results=$this_num_results

done

# 結果を標準出力に出力する
cat $TMPFILE

rm -f $TMPFILE

if [ $VERBOSE -eq 1 ]; then echo "Completed `date`"; fi >&2
