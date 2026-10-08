#!/bin/sh

baseurl="https://docs.google.com/spreadsheets/d/1bu_bTbRqT2v_KlDyGioiMpb_AlP3MF7SqZ7Z7Bb-bZY/export?format=tsv&gid="
gid_property="1617257216"
gid_class="860642140"
gid_dataset="2114228295"

curl -sL "${baseurl}${gid_property}" | sed 's/\r//g' | awk '1' > property.tsv
curl -sL "${baseurl}${gid_class}" | sed 's/\r//g' | awk '1' > class.tsv
curl -sL "${baseurl}${gid_dataset}" | sed 's/\r//g' | awk '1' > dataset.tsv
