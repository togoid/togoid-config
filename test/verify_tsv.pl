#!/usr/bin/env perl

# dataset.yamlから各データベースのIDに関する正規表現を取得し、
# 実際に出力されているTSVのそれに対して適用する。

use warnings;
use strict;
use Fatal qw/open/;
use open ":utf8";
use YAML::XS;
use File::Slurp;
use File::Basename;
use Cwd;
$| = 1;

$ARGV[0] or die $!;
my $filename = $ARGV[0];
my $yaml = read_file("../config/dataset.yaml");
my $array = Load $yaml;
my $pair = basename $filename, ".tsv";
my ($src, $dst) = split "-", $pair, 2;
(my $pattern_1 = $array->{$src}->{"regex"}) =~ s,\$$,,;
(my $pattern_2 = $array->{$dst}->{"regex"}) =~ s,^\^,,;
my $final_pattern = $pattern_1 . "\\t" . $pattern_2;
$final_pattern =~ s/<id\d>/<id>/g;
for (my $_id = 1; $final_pattern =~ /<id>/; $_id++){
  $final_pattern =~ s//<id${_id}>/;
}
#  system("wc -l $dirname/$filename");
print "# ", $filename, "\t", $final_pattern, "\n";
#  system("head -500 $dirname/$filename | grep -vP '$pattern'");
#  system("grep -vP '$final_pattern' $dirname/$filename > not_matched/$filename");
#  my $regex = qr($final_pattern);
open(my $fh, $filename);
my $count = 0;
while(<$fh>){
  chomp;
  my ($src, $dst) = split /\t/;
  if (/$final_pattern/){
    my ($first, $second) = ("", "");
    for(my $_c=1; $_c < 10; $_c++){
      my $cname = "id$_c";
      if($+{$cname}){
        if($first){
          $second = $+{$cname};
        }else{
          $first = $+{$cname};
        }
      }
    }
    if(($src ne $first || $dst ne $second) && $count < 5){
      print join("\t", ("TSV error", $pair, $src, $first, $dst, $second)), "\n";
      $count++;
    }
  }else{
    print join("\t", ("Regex error", $pair, $src, $dst)), "\n";
  }
}
close($fh);

__END__
