#!/usr/bin/env perl

use strict;
use JSON;
use URI::Escape;
use LWP::UserAgent;
use threads;
use Thread::Semaphore;
use threads::shared;

# Thread limit of SPARQL query
my $thread_limit = 10;

# Endpoint
our $EP = "https://integbio.jp/rdf/mirror/uniprot/sparql";
our $EP_MIRROR = "https://sparql.uniprot.org/sparql";

# SPARQL query for get-taxonomy-list
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

# SPARQL query for get-ID-list
our $QUERY = "PREFIX up: <http://purl.uniprot.org/core/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX db: <http://purl.uniprot.org/database/>
PREFIX tax: <http://purl.uniprot.org/taxonomy/>
SELECT DISTINCT ?source ?target
WHERE {
  ?source a up:Protein ;
           up:organism __TAXON__ ;
           rdfs:seeAlso [
    up:database db:RefSeq ;
    rdfs:comment ?target ] .
}";

# regex : req. double escape backslash (e.g. '\d' -> '\\d')
our $SOURCE_REGEX = "http://purl.uniprot.org/uniprot/(.+)";
our $TARGET_REGEX = "(.+)\\.\\d";

##########################

# for resume 
our %LOG;
if (-f "./log") {
    open(DATA, "./log");
    while (<DATA>) {
        chomp($_);
        my @a = split(/\t/, $_);
        $LOG{$a[0]} = 1 if ($a[1] =~ /^\d+$/);
    }
    close DATA;
}

our $LOOPC : shared = 0;
our $THREAD_COUNT : shared = 0;
$| = 1;
our $SEMA = new Thread::Semaphore($thread_limit);
 
my %th;

# get taxonomy list
my $json = &get("?query=".uri_escape($query_tax));

# make threads
for my $id (0 .. $#{$json->{results}->{bindings}}) {
    $th{$id} = new threads(\&run, $id, ${$json->{results}->{bindings}}[$id], $SEMA);
}

for (0 .. $#{$json->{results}->{bindings}}) {
    $th{$_}->join();
}

# finish flag
system("mv ./log ./log.bk");

# run threads
sub run {
    my ($id, $d, $sema) = @_;

    my $json;
    
    $sema->down();   
    {lock $THREAD_COUNT; $THREAD_COUNT++;}
    {lock $LOOPC; $LOOPC++;}

    my $tax = $d->{org}->{value};
    $tax =~ s/http:\/\/purl\.uniprot\.org\/taxonomy\//tax:/;
    return 0 if ($LOG{$tax});  # for resume

    # get ID list
    my $query_main = $QUERY;
    print STDERR $tax, "\t";
    $query_main =~ s/__TAXON__/${tax}/;
    $json = &get("?query=".uri_escape($query_main));
    print STDERR $#{$json->{results}->{bindings}} + 1, "\n";

    threads::yield();
    
    {lock $THREAD_COUNT; $THREAD_COUNT--;}
    $sema->up();

    foreach my $el (@{$json->{results}->{bindings}}) {
	$el->{source}->{value} =~ s/^${SOURCE_REGEX}$/$1/;
	$el->{target}->{value} =~ s/^${TARGET_REGEX}$/$1/;
	print $el->{source}->{value}, "\t", $el->{target}->{value}, "\n";
    }
}

sub get {
    my $params = $_[0];
    
    my $ua = LWP::UserAgent->new;
    
    my $srj = $ua -> get($EP.$params, 'Accept' => 'application/sparql-results+json') -> content;
    eval {
	decode_json($srj);
	1
    } or do {
	$srj = $ua -> get($EP_MIRROR.$params, 'Accept' => 'application/sparql-results+json') -> content if ($EP_MIRROR);
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
