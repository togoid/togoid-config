#!/usr/bin/env perl

=head

TogoID APIの動作確認をするためのスクリプト

tsvファイルを引数として取得する。
第一列のIDをランダムに NofIDs 件抽出し、API引数のidsに与える。
routeとして、tsvファイルの第一列と第二列のDBを指定する。
tsvファイルの第二列のIDが、APIの返却するIDとして得られるか確認する。

=cut

use warnings;
use strict;
use Fatal qw/open/;
use open ":utf8";
use URI;
use URI::QueryParam;
use constant ENDPOINT => "https://api.togoid.dbcls.jp/convert";
use constant LIMIT => 10000;
use constant NofIDs => 50;
require HTTP::Request;
use LWP::UserAgent;
use File::Basename;
use POSIX;
use Statistics::Distribution::Generator qw( :all );
use JSON::XS;
use Data::Dumper;

# /data/togoid/link/20210525/output/tsv/affy_probeset-ncbigene.tsv

sub get_results {
    my $offset = shift;
    my $source = shift;
    my $src_db = shift;
    my $tgt_db = shift;
    my $ep = URI->new( ENDPOINT );
    $ep->query_form_hash({
	ids     => join(",", @$source),
	route   => "$src_db,$tgt_db",
	limit   => LIMIT,
	offset  => $offset,
	include => "pair",
	total   => "true",
	'format'  => "json",
    });

    my $request = HTTP::Request->new("GET" => $ep);
#    $request->header( "Accept" => "application/json" );
    my $ua = LWP::UserAgent->new();
#    $ua->timeout(180);
    my $res = $ua->request($request);
    (my $req_str = $request->as_string) =~ s/[\r\n]+.*$//sm;
    if ($res->is_success) {
	my $result = decode_json $res->content;
#    print Dumper $result;
	return ($result, $req_str);
    } else {
        warn join("\t", ("E", $src_db."-".$tgt_db, scalar localtime(), $res->status_line, $req_str)), "\n";
	return ("", $req_str);
    }
}

(my $path = $ARGV[0]) || die $!;
my $filename = basename( $path, ".tsv" );
my ($src_db, $tgt_db) = split /-/, $filename;
my $line_count = `wc -l < $path`;
chomp( $line_count );
print "$src_db -> $tgt_db: ";
print $line_count, "\n";

my @line_number;
for (my $_i = 0; $_i < NofIDs ; $_i++){
    push @line_number, floor( uniform(1, $line_count) );
}
@line_number = sort {$a <=> $b} @line_number;

my (@source, @target);
open(my $fh, $path);
my ($i, $j) = (0, 0);
while(<$fh>){
    $i++;
    if ($line_number[$j] == $i){
	chomp;
	my ($src, $tgt) = split /\t/;
	push @source, $src;
	push @target, $tgt;
	$j++;
	if ($j == @line_number){
	    last;
	}
    }
}
close($fh);

my %for_check;
my @requests;
for ( my $_offset = 0; ; $_offset++ ){
    my ($result, $qs) = get_results( $_offset * LIMIT, \@source, $src_db, $tgt_db );
    push @requests, $qs;
    if( not $result ){
	$for_check{"-"}{"-"}++;
	last;
    }
    for my $r ( @{ $result->{"results"} } ){
	$for_check{$r->[0]}{$r->[1]} = scalar @requests;
    }
    if( not defined $result->{"total"} ){
	print "Total not obtained.\t$qs\n";
	warn "No total >> ${src_db}-${tgt_db} [ $qs ]\n";
	warn Dumper $result;
	last;
    }
    warn join("\t", ("S", $src_db."-".$tgt_db, scalar localtime(), "(". $_offset. ")", $result->{"total"})), "\n";
    if( $result->{"total"} < ($_offset + 1) * LIMIT ){
	last;
    }
}

if (defined $for_check{"-"}{"-"}){
    print join("\t", ("Error occurred", "${src_db}-${tgt_db}", scalar @requests, $requests[0])), "\t";
} else {
    for (my $_i = 0; $_i < @source; $_i++ ){
	if( not defined $for_check{$source[$_i]}{$target[$_i]} ){
	    print join("\t", ("Missing pair", "${src_db}-${tgt_db}")), "\t";
	    print join("\t", ($source[$_i], $target[$_i])), "\t";
	    print join("\t", (scalar @requests, $requests[0])), "\n";
	}
    }
}

__END__
