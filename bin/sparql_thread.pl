#!/usr/bin/env perl

# 20220926 moriya # human のようにタイムアウトする場合に、強制 0-9 で分割する機能（参考：chembl_compound-chembl_target/update_params.pl の FORCE_SPLIT)
# 20210510 moriya # result limit 超えた場合に IDやtaxonomy番号の末尾 0-9 で分割できるように $QUERY_SPLIT クエリ追加（参考：uniprot-ec/update_params.pl)
# 20210507 moriya # Endpointエラーの場合300秒待って再施行（10回まで）
# 20210402 moriya
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
# Usage: update.pl > pair.tsv (-t [integer] -d)
#   -t [integer] : スレッド数を強制指定
#   -d : debug
#     - 終了時 log ファイルが log.ok になっていれば正常終了
#     - fetch error などで log ファイル残っている場合
#       update.pl -d >> pair.tsv で途中から再開して追記
#
# Endpoint の結果の Limit を判定
#   - binsings 数が 10000 で割り切れたら Limit かもしれないので limit, offset, order で回し直す
#     ('x-sparql-maxrows' header は virtuoso は返すが、SPARQL-proxyは返さない。他のトリプルストアも不明)

use Getopt::Std;
use JSON;
use URI::Escape;
use LWP::UserAgent;
use threads;
use threads::shared;

require './update_params.pl';

my %OPT;
getopts('t:d', \%OPT);
$THREAD_LIMIT = $OPT{t} if ($OPT{t});
our $DEBUG = 1 if ($OPT{d});

our $SLEEP_TIME = 60; # sec.
our $TRIAL_MAX = 10;
our $TRIAL_COUNT = 0;

# for resume
our %LOG;
if (-f "./log") {
    if ($DEBUG) {
	open(DATA, "./log");
	open(OUT, "> ./log_n");
	while (<DATA>) {
	    chomp($_);
	    my @a = split(/\t/, $_);
	    if ($a[1] =~ /^\d+$/) {
		$LOG{$a[0]} = 1;
		print OUT $_,"\n";
	    }
	}
	close DATA;
	close OUT;
	system("mv ./log_n ./log");
    } else {
	system("rm ./log");
    }
}
    

# varables for threads
$| = 1;  # 標準出力のコマンドバッファリング有効

# get taxonomy list
our @LIST : shared;
my $json = &get($QUERY_TAX, "First-query:");
our $TAXON = 0;
foreach my $d (@{$json->{results}->{bindings}}) {
    my $uri;
    if ($d->{org}) {
	$uri = $d->{org}->{value};
	$TAXON = 1;
    } elsif ($d->{tax}) {
	$uri = $d->{tax}->{value};
	$TAXON = 1;
    } elsif ($d->{target}) {
	$uri = $d->{target}->{value};
    } else {
	&log("SPARQL error: First SPARQL result needs ?org or ?tax or ?target.\n");
	print STDERR "SPARQL error: First SPARQL result needs ?org or ?tax or ?target.\n";
	exit 0;
    }
    push(@LIST, $uri);
}

# make threads
for (1..$THREAD_LIMIT) {
    my $thr = threads->new(\&worker);
}

foreach my $thr (threads->list){
    $thr->join;
}

# finish flag
if ($DEBUG){
    my $e = `grep error ./log|wc -l`;
    if ($e >= 1) {
	print STDERR "Error: refer to './log'\n";
    } else {
	system("mv ./log ./log.ok") if(-f "./log");
    }
}

# run threads
sub worker {
    my $uri = undef;
    {
	lock @LIST;
	$uri = shift(@LIST) if($#LIST >= 0);
    }
    while($uri){
	my $r = &run($uri);
	$uri = undef;
	{
	    lock @LIST;
	    $uri = shift(@LIST) if($#LIST >= 0);
	}
    }
}

# each run
sub run {
    my ($uri) = @_;
    
    my $tmp_id = $uri;
    my $query_main = $QUERY;
    $tmp_id =~ s/^.+\/([^\/]+)$/$1/;
    if ($TAXON) {
	$tmp_id = "tax:".$tmp_id;
	$query_main =~ s/__TAXON__/${uri}/;
    } else {
	$tmp_id = "target:".$tmp_id;
	$query_main =~ s/__TARGET__/${uri}/;
    }
    
    # get ID list
    my $json = 0;
    $json = &get($query_main, $tmp_id, $uri) if (!$LOG{$tmp_id});  # for resume
    
    if ($json->{results} && !$LOG{$tmp_id}) {  # for resume
	foreach my $el (@{$json->{results}->{bindings}}) {
	    $el->{source}->{value} =~ s/^${SOURCE_REGEX}$/$1/;
	    $el->{target}->{value} =~ s/^${TARGET_REGEX}$/$1/;
	    print $el->{source}->{value}, "\t", $el->{target}->{value}, "\n";
	}
	&log($tmp_id."\t".($#{$json->{results}->{bindings}} + 1)."\n");
    }
    return 1;
}

sub get {
    my ($query, $tmp_id, $uri) = @_;

    my $json;
    my $force_split = 0;
    if ($FORCE_SPLIT{$tmp_id}) {
      $force_split = 1;
    } else {
      $json = &get_req("?query=".uri_escape($query), $tmp_id, 1);
      $force_split = 1 if ($json == 1);
      return 0 if (!$json) ;
    }

    ## Endpoint result-limit check
    if ($force_split || (($#{$json->{results}->{bindings}} + 1) > 0 && ($#{$json->{results}->{bindings}} + 1) % 10000 == 0)) {
	my @page = ();
	if ($QUERY_SPLIT) { # if split-query (using 0-9 number) in the update_params.pl (ref. uniprot-ec)
	  &log("split by num: ".$tmp_id."\n");
	    for (my $i = 0; $i < 10; $i++) {
		my $query_sp = $QUERY_SPLIT;
		$query_sp =~ s/__NUMBER__/${i}/;
		if ($TAXON) {
		    $query_sp =~ s/__TAXON__/${uri}/;
		} else {
		    $query_sp =~ s/__TARGET__/${uri}/;
		}
		$json = &get_req("?query=".uri_escape($query_sp), $tmp_id." split:".$i);
		return 0 if (!$json) ;
		push(@page, @{$json->{results}->{bindings}});
	    }
	} else {
	    my $limit = $#{$json->{results}->{bindings}} + 1;
	    # get with limit, offset & order
	    my $order = "?source";
	    $order = "?org ?tax ?target" if ($tmp_id eq "First-query:");
	    while (($#{$json->{results}->{bindings}} + 1) == $limit) {
		my $offset = $loop * $limit;
		$json = &get_req("?query=".uri_escape($query." ORDER BY ".$order." LIMIT ".$limit." OFFSET ".$offset), $tmp_id);
		return 0 if (!$json) ;
		push(@page, @{$json->{results}->{bindings}});
	    }
	}
	@{$json->{results}->{bindings}} = @page;
    }
    
    return $json;
}

sub get_req {
    my ($params, $e, $pre_query) = @_;
    
    my $ua = LWP::UserAgent->new;

    my $res;
    my $err = "";
    my $flag = 0;
    while ($TRIAL_COUNT < $TRIAL_MAX && !$flag) {
	$res = $ua -> get($EP.$params, 'Accept' => 'application/sparql-results+json');
	eval {
	    decode_json($res -> content);
	    $flag = 1;
	    1
	} or do {
	    $err .= "Endpoint ".$EP." : ".$res -> status_line."; ";
	    $res = $ua -> get($EP_MIRROR.$params, 'Accept' => 'application/sparql-results+json') if ($EP_MIRROR);
	};

	eval {
	    decode_json($res -> content);
	    $flag = 1;
	    1
	} or do {
	    sleep($SLEEP_TIME);
	    $TRIAL_COUNT++;
	    $err .= "Endpoint ".$EP_MIRROR." : ".$res -> status_line."; " if ($EP_MIRROR);
	    return 1 if ($pre_query && $QUERY_SPLIT);
	    if ($TRIAL_COUNT == $TRIAL_MAX - 1) {
		&log($e."\tFetch error: ".$err."\n");
		print STDERR $e, "\tFetch error: ", $err, "\n";
	        exit 1;
	    }
	};
    }

    return decode_json($res -> content);
}

sub log{
    my $err = $_[0];
    if ($DEBUG) {
	open(my $fh, ">> ./log");
	flock $fh, LOCK_EX;
	print $fh $err;
	close $fh;
    }
}
