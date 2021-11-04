# TSVファイルやAPIをテストするスクリプト置き場

## TSVファイルを確認する

```
$ mkdir tsv_check-$(date -I); \
find /data/togoid/link/current/output/tsv -type f | xargs -i -P20 sh -c "FN=\$(basename {}); echo \$FN; ./verify_tsv.pl {} | gzip -c > tsv_check-$(date -I)/\${FN}.gz"
```

## TogoIDのAPIをテストする

以下の要領で実行する。
`test_api.pl` 内で、constantであるNofIDsにより、一度のAPI呼び出しで引数に含めるIDの数を定義している。
```
$ mkdir api_test_results-$(date -I); \
(find /data/togoid/link/current/output/tsv/ -type f | xargs -i -P5 sh -c "fn=\$(basename {} .tsv); ./test_api.pl {} > api_test_results-$(date -I)\$fn") 2> warnings-$(date -I).txt
```
