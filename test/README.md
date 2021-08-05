# TogoIDのAPIをテストする

以下の要領で実行する。
test_api.pl 内で、一度のAPI呼び出しで引数に含めるIDの数を定義している。
```
$ mkdir api_test_results-$(date -I); \
(find /data/togoid/link/current/output/tsv/ -type f | xargs -i -P5 sh -c "fn=\$(basename {} .tsv); ./test_api.pl {} > api_test_results-$(date -I)\$fn") 2> warnings-$(date -I).txt
```
