#!/usr/bin/env perl

use warnings;
use strict;
use Fatal q/open/;
use open ":utf8";

while(<>){
  chomp;
  if (index($_, '"http') != 0){
    next;
  }
  my @vals = split /\t/;
  $vals[0] =~ m/DOID_(\d+)/;
  chop($vals[1]);
  my $g1 = substr($vals[1], rindex($vals[1], "/") + 1);
  print $g1, "\t", $1, "\n";
  if( defined($vals[2]) ){
    chop($vals[2]);
    my $g2 = substr($vals[2], rindex($vals[2], "/") + 1);
    print $g2, "\t", $1, "\n";
  }
}

__END__
