#!/usr/bin/env perl

# 20210202 moriya

use JSON;
use URI::Escape;
use LWP::UserAgent;
use threads;
use Thread::Semaphore;
use threads::shared;

require './update_params.pl';

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
our $SEMA = new Thread::Semaphore($THREAD_LIMIT);
 
my %th;

# get taxonomy list
my $json = &get("?query=".uri_escape($QUERY_TAX), "get tax:");

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
    my $tax_tmp = $tax;
    $tax_tmp =~ s/^.+\/(\d+)$/tax:$1/;
    return 0 if ($LOG{$tax_tmp});  # for resume

    # get ID list
    my $query_main = $QUERY;
    $query_main =~ s/__TAXON__/${tax}/;
    $json = &get("?query=".uri_escape($query_main), $tax_tmp);
    print STDERR $tax_tmp, "\t", $#{$json->{results}->{bindings}} + 1, "\n";

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
    my ($params, $e) = @_;
    
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
	print STDERR $e, "\tFetch error.\n";
	exit 0;
    };
    
    return decode_json($srj);
}
