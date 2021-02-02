#!/usr/bin/env perl

use strict;
use LWP::UserAgent;

my $ua = LWP::UserAgent->new;

## get from LinkDB
my $tsv = $ua -> get("https://rest.genome.jp/link/go/ko", 'Accept' => 'application/sparql-results+json') -> content;

my @lines = split(/\n/, $tsv);

foreach my $el (@lines) {
    my @a = split(/\t/, $el);
    $a[0] =~ s/ko://;
    $a[1] =~ s/go:/GO_/;
    print $a[0], "\t", $a[1], "\n";
}
