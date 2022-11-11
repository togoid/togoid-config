#!/usr/bin/env perl
$d = `wget -O - --quiet --no-check-certificate "https://ega-archive.org/metadata/v2/studies?limit=0" | grep egaStableId`;
@a = split(/\n/, $d);
foreach $l (@a) {
  if ($l =~ /"egaStableId" : "(EGAS\d+)"/) {
   $id = $1;
   $d2 = `wget -O - --quiet --no-check-certificate https://egatest.crg.eu/webportal/v1/citations/studies/${id}/articles | grep pmid`;
   @a2 = split(/\n/, $d2);
   foreach $l2 (@a2) {
    if ($l2 =~ /"pmid" : (\d+)/) { print $id,"\t", $1,"\n"; }
   }
  }
}
