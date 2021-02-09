#!/usr/bin/env perl

# 20210209 moriya
# 20210203 moriya

# 1. 生物種リストをSPARQLで取得して、種毎にIDリストをSPARQLで並列に取得
#   - e.g. uniprot-refseq/update_params.pl
# 2. ターゲットリストをSPARQLで取得して、ターゲット毎にIDリストをSPARQLで並列に取得
#   - ターゲットが Ontology や Ortholog group のように種類が限られている時に
#   - e.g. uniprot-pfam/update_params.pl
#
# SPARQLクエリやprefix、並列スレッド数は update_params.pl に記述
#   - Opt. '-t [integer]': スレッド数を強制指定
#
# Usage: update.pl > pair.tsv (-t [integer])
#   - 終了時 log ファイルが log.bk になっていれば正常終了
#   - fetch error などで log ファイル残っている場合
#     update.pl >> pair.tsv で途中から再開して追記
#
# Endpoint の結果の Limit を判定
#   - binsings 数が 10000 で割り切れたら Limit かもしれないので limit, offset, order で回し直す
#     ('x-sparql-maxrows' header は virtuoso は返すが、SPARQL-proxyは返さない。他のトリプルストアも不明)

use Getopt::Std;
use JSON;
use URI::Escape;
use LWP::UserAgent;
use threads;
use Thread::Semaphore;
use threads::shared;

require './update_params.pl';

my %OPT;
getopts('t:', \%OPT);
$THREAD_LIMIT = $OPT{t} if ($OPT{t});

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

# varables for threads
our $LOOPC : shared = 0;
our $THREAD_COUNT : shared = 0;
$| = 1;
our $SEMA = new Thread::Semaphore($THREAD_LIMIT);
my %th;

# get taxonomy list
my $json = &get($QUERY_TAX, "First-query:");

# make threads
for my $id (0 .. $#{$json->{results}->{bindings}}) {
    $th{$id} = new threads(\&run, $id, ${$json->{results}->{bindings}}[$id], $SEMA);
}

for (0 .. $#{$json->{results}->{bindings}}) {
    $th{$_}->join();
}

# finish flag
system("mv ./log ./log.bk") if(-f "./log");

# run threads
sub run {
    my ($id, $d, $sema) = @_;
    
    $sema->down();   
    {lock $THREAD_COUNT; $THREAD_COUNT++;}
    {lock $LOOPC; $LOOPC++;}

    my $uri;
    my $taxon = 0;
    if ($d->{org}) {
	$uri = $d->{org}->{value};
	$taxon = 1;
    } elsif ($d->{tax}) {
	$uri = $d->{tax}->{value};
	$taxon = 1;
    } elsif ($d->{target}) {
	$uri = $d->{target}->{value};
    } else {
	&log("First SPARQL result needs ?org or ?tax or ?target.\n");
	exit 0;
    }

    my $tmp_id = $uri;
    my $query_main = $QUERY;
    $tmp_id =~ s/^.+\/([^\/]+)$/$1/;
    if ($taxon){
	$tmp_id = "tax:".$tmp_id;
	$query_main =~ s/__TAXON__/${uri}/;
    } else {
	$tmp_id = "target:".$tmp_id;
	$query_main =~ s/__TARGET__/${uri}/;
    }

    # get ID list
    my $json = &get($query_main, $tmp_id) if (!$LOG{$tmp_id});  # for resume
    threads::yield();
    
    {lock $THREAD_COUNT; $THREAD_COUNT--;}
    $sema->up();

    return 0 if ($LOG{$tmp_id});  # for resume

    foreach my $el (@{$json->{results}->{bindings}}) {
	next if (!$el->{source} || !$el->{source}->{value} || !$el->{target} || !$el->{target}->{value});
	$el->{source}->{value} =~ s/^${SOURCE_REGEX}$/$1/;
	$el->{target}->{value} =~ s/^${TARGET_REGEX}$/$1/;
	print $el->{source}->{value}, "\t", $el->{target}->{value}, "\n";
    }
    &log($tmp_id."\t".($#{$json->{results}->{bindings}} + 1)."\n");
}

sub get {
    my ($query, $tmp_id) = @_;

    my $json = &get_req("?query=".uri_escape($query), $tmp_id);
    
    ## Endpoint result-limit check
    if (($#{$json->{results}->{bindings}} + 1) % 10000 == 0) {
	my $limit = $#{$json->{results}->{bindings}} + 1;
	@{$json->{results}->{bindings}} = [];
	# get with limit, offset & order
	my $order = "?source";
	$order = "?org ?tax ?target" if ($tmp_id eq "First-query:");
	while (($#{$json->{results}->{bindings}} + 1) == $limit) {
	    my $offset = $loop * $limit;
	    my $page = &get_req("?query=".uri_escape($query." ORDER BY ".$order." LIMIT ".$limit." OFFSET ".$offset), $tmp_id);
	    push(@{$json->{results}->{bindings}}, @{$page->{results}->{bindings}});
	}
    }
    return $json;
}

sub get_req {
    my ($params, $e) = @_;
    
    my $ua = LWP::UserAgent->new;
    
    my $res = $ua -> get($EP.$params, 'Accept' => 'application/sparql-results+json');
    my $err = "";
    eval {
	decode_json($res -> content);
	1
    } or do {
	$err .= "Endpoint ".$EP." : ".$res -> status_line."; ";
	$res = $ua -> get($EP_MIRROR.$params, 'Accept' => 'application/sparql-results+json') if ($EP_MIRROR);
    };

    eval {
	decode_json($res -> content);
	1
    } or do {
	$err .= "Endpoint ".$EP_MIRROR." : ".$res -> status_line."; " if ($EP_MIRROR);
	&log($e."\tFetch error: ".$err."\n");
	print STDERR $e, "\tFetch error: ", $err, "\n";
	exit 0;
    };
    
    return decode_json($res -> content);
}

sub log{
    my $err = $_[0];
    open(my $fh, ">> ./log");
    flock $fh, LOCK_EX;
    print $fh $err;
    close $fh;
}
