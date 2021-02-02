#!/usr/bin/env perl

use strict;
use JSON;
use URI::Escape;
use LWP::UserAgent;

my $query = "PREFIX wp: <http://vocabularies.wikipathways.org/wp#>
SELECT DISTINCT ?pathway ?doid
WHERE {
  ?pathway a wp:Pathway ;
           wp:diseaseOntologyTag ?doid .
}";
    
my $json = &get("?query=".uri_escape($query));

foreach my $el (@{$json->{results}->{bindings}}) {
    $el->{pathway}->{value} =~ s/http:\/\/identifiers\.org\/wikipathways\///;
    $el->{doid}->{value} =~ s/http:\/\/purl\.obolibrary\.org\/obo\///;
    print $el->{pathway}->{value}, "\t", $el->{doid}->{value}, "\n";
}

sub get {
    my $params = $_[0];
    
    my $ep = "http://sparql.wikipathways.org/sparql";
    
    my $ua = LWP::UserAgent->new;
    
    my $srj = $ua -> get($ep.$params, 'Accept' => 'application/sparql-results+json') -> content;

    eval {
	decode_json($srj);
	1
    } or do {
	print STDERR "fetch error. (malformed JSON string)\n";
	exit 0;
    };
    
    return decode_json($srj);
}
