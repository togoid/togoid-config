#!/usr/bin/env perl

use strict;
use JSON;
use URI::Escape;
use LWP::UserAgent;

=pos
my %log;
if (-f "./log") {
    open(DATA, "./log");
    while (<DATA>) {
        chomp($_);
        my @a = split(/\t/, $_);
        $log{$a[0]} = 1 if ($a[1] =~ /^\d+$/);
    }
    close DATA;
}
=cut

my $query_tax = "PREFIX up: <http://purl.uniprot.org/core/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX db: <http://purl.uniprot.org/database/>
SELECT DISTINCT ?org
WHERE {
  ?org ^up:organism [ 
    a up:Protein ;
    rdfs:seeAlso [ 
      up:database db:RefSeq
    ] ] .
}";

my $query = "PREFIX up: <http://purl.uniprot.org/core/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX db: <http://purl.uniprot.org/database/>
PREFIX tax: <http://purl.uniprot.org/taxonomy/>
SELECT DISTINCT ?uniprot ?opponent
WHERE {
  ?uniprot a up:Protein ;
           up:organism __TAXON__ ;
           rdfs:seeAlso [
    up:database db:RefSeq ;
    rdfs:comment ?opponent ] .
}";

# get tax with seeAlso-database
my $json = &get("?query=".uri_escape($query_tax));

# get list at each tax
foreach my $res (@{$json->{results}->{bindings}}) {
    my $tax = $res->{org}->{value};
    $tax =~ s/http:\/\/purl\.uniprot\.org\/taxonomy\//tax:/;
#    next if ($log{$tax});
    
    print STDERR $tax, "\t";
    
    my $query_tmp = $query;
    $query_tmp =~ s/__TAXON__/${tax}/;
    my $json = &get("?query=".uri_escape($query_tmp));
    
    print STDERR $#{$json->{results}->{bindings}} + 1, "\n";
    
    foreach my $el (@{$json->{results}->{bindings}}) {
	$el->{uniprot}->{value} =~ s/http:\/\/purl\.uniprot\.org\/uniprot\///;
	$el->{opponent}->{value} =~ s/\.\d+$//;
	print $el->{uniprot}->{value}, "\t", $el->{opponent}->{value}, "\n";
    }
}

#system("mv log log.bk");

sub get {
    my $params = $_[0];
    
    my $ep = "https://integbio.jp/rdf/mirror/uniprot/sparql";
    my $ep_mirror = "https://sparql.uniprot.org/sparql";
    
    my $ua = LWP::UserAgent->new;
    
    my $srj = $ua -> get($ep.$params, 'Accept' => 'application/sparql-results+json') -> content;
    eval {
	decode_json($srj);
	1
    } or do {
	$srj = $ua -> get($ep_mirror.$params, 'Accept' => 'application/sparql-results+json') -> content;
    };

    eval {
	decode_json($srj);
	1
    } or do {
	print STDERR "Fetch error.\n";
	exit 0;
    };
    
    return decode_json($srj);
}
