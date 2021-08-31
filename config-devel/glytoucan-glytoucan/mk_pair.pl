#!/usr/bin/env perl

#
# curl -o wurcs_glytoucan_subsumption.csv -sH 'Accept: text/csv' --data-urlencode query@query.rq https://ts.glycosmos.org/sparql
#

use warnings;
use strict;
use Fatal qw/open/;
use open ":utf8";

my $first = 1;
my $last_md5  = "";
my @glytoucan_id_list;

open(my $fh, "wurcs_glytoucan_subsumption.csv");

while(<$fh>){
  if( $first ){
    $first = 0;
    next;
  }
  s/\W*$//;
  my ($md5, $glytoucan_id) = split /,/;
  if( $last_md5 eq $md5 ){
    push @glytoucan_id_list, $glytoucan_id;
  } else {
    if( scalar @glytoucan_id_list >= 2 && scalar @glytoucan_id_list <= 50 ){
      for( my $i = 0; $i < @glytoucan_id_list; $i++ ){
        print join("\n", map { $glytoucan_id_list[$i]. "\t". $_ } @glytoucan_id_list), "\n";
      }
    }
    @glytoucan_id_list = ();
    push @glytoucan_id_list, $glytoucan_id;
  }
  $last_md5 = $md5;
}

close($fh);

if( @glytoucan_id_list >= 2 && @glytoucan_id_list <= 50 ){
  for( my $i = 0; $i < @glytoucan_id_list; $i++ ){
    print join("\n", map { $glytoucan_id_list[$i]. "\t". $_ } @glytoucan_id_list), "\n";
  }
}

__END__
