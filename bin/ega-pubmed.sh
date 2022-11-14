#!/bin/sh

for i in `wget -O - --quiet --no-check-certificate "https://ega-archive.org/metadata/v2/studies?limit=0" | awk -F ":" '/"egaStableId" : "EGAS/ {  print $2 }' | sed -e 's/[",]//g'`
do
  for j in `wget -O - --quiet --no-check-certificate https://egatest.crg.eu/webportal/v1/citations/studies/${i}/articles | awk -F ":" '/"pmid"/ { print $2 }'`
  do
    echo "${i}\t${j}"
  done
done
