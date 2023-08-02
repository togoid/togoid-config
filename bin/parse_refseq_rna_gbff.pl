#!/usr/bin/perl

# RefSeq RNA の flat file (GBFF) から各種 ID を抽出する
#
# flat file 形式に関する詳細は下記を参照
# https://www.ddbj.nig.ac.jp/ddbj/flat-file.html
#
# usage:
# gzip -dc human.*.rna.gbff.gz | ./parse_refseq_rna_gbff.pl
#
# options:
#   --summary    RefSeq RNA と各種 ID の対応を1行に出力（デフォルト）
#   --pmid       RefSeq RNA -> PubMed ID の対応を出力
#   --taxon      RefSeq RNA -> Taxonomy ID の対応を出力
#   --symbol     RefSeq RNA -> Gene Symbol の対応を出力
#   --geneid     RefSeq RNA -> Gene ID の対応を出力
#   --hgnc       RefSeq RNA -> HGNC ID の対応を出力
#   --mim        RefSeq RNA -> MIM number の対応を出力
#   --protein    RefSeq RNA -> RefSeq Protein の対応を出力
#   --dbsnp      RefSeq RNA -> dbSNP の対応を出力
#
# 作成: Yuki Naito (DBCLS)

use warnings ;
use strict ;
use Getopt::Long ;

# ▼ コマンドラインオプションの取得
my (
	$summary_op,
	$pmid_op,
	$taxon_op,
	$symbol_op,
	$geneid_op,
	$hgnc_op,
	$mim_op,
	$protein_op,
	$dbsnp_op,
) ;
GetOptions(
	'summary' => \$summary_op,
	'pmid'    => \$pmid_op,
	'taxon'   => \$taxon_op,
	'symbol'  => \$symbol_op,
	'geneid'  => \$geneid_op,
	'hgnc'    => \$hgnc_op,
	'mim'     => \$mim_op,
	'protein' => \$protein_op,
	'dbsnp'   => \$dbsnp_op,
) ;
$summary_op = 1 unless (  # オプション未指定の場合は --summary を指定（デフォルト）
	$summary_op or
	$pmid_op or
	$taxon_op or
	$symbol_op or
	$geneid_op or
	$hgnc_op or
	$mim_op or
	$protein_op or
	$dbsnp_op
) ;
# ▲ コマンドラインオプションの取得

$/ = "\n//\n" ;  # Flat file (GBFF) 形式におけるレコードの区切り文字列「//」
                 # を入力レコードセパレータ変数（$/）にセットすることにより、
                 # 1エントリずつ while() で読み込んで処理する。

while (<>){
	my $gbff = $_ ;

# LOCUS を抽出
#   データベース中でそのエントリのみが持つユニークな値が付けられている。
#   RefSeq においては、RefSeq accession（例：NM_123456）が記載されている。
	my $locus = ($gbff =~ /
		^LOCUS\ +(\S+)
	/mx) ? $1 : '' ;

# VERSION を抽出
#   RefSeq においては、accession.version（例：NM_123456.7）が記載されている。
#   当該エントリの塩基配列が訂正・更新されると version が変わることになる。
#   前述の LOCUS と VERSION のどちらを主 ID に利用するかは要検討。
#   TogoID では version 情報までは不要なので、LOCUS を採用することにした。
	my $version = ($gbff =~ /
		^VERSION\ +(\S+)
	/mx) ? $1 : '' ;

# REFERENCE を抽出
#   このなかの PUBMED に PubMed ID (PMID) が記載されている。
#   複数記載されているため while() ですべてのパタンマッチを抽出。
#   出力オプション未指定の場合は、カンマ区切りの ID リストを作成。
	my $pubmed_all = '';
	while ($gbff =~ /
		^(REFERENCE\ .*?)  # REFERENCE 全体にマッチ
		^(?=\S)            # 次の項目の開始位置の手前まで
	/smxg and ($pmid_op or $summary_op)){
		my $reference = $1 ;

# REFERENCE -> PUBMED を抽出
#   PubMed ID (PMID)（整数）
		my $pubmed = ($reference =~ /
			^\ +PUBMED\ +(\S+)
		/mx) ? $1 : '' ;
		print "$locus	$pubmed\n" if $pmid_op ;  # RefSeq RNA -> PubMed ID の対応を出力
		if ($pubmed ne '') {
			$pubmed_all .= ',' . $pubmed;
		}
	}
	$pubmed_all =~ s/^,//g;

# FEATURES 全体を抽出
#   Feature Table だよ。
	my $features = ($gbff =~ /
		^(FEATURES\ .*?)  # FEATURES 全体にマッチ
		^(?=\S)           # 次の項目の開始位置の手前まで
	/smx) ? $1 : '' ;

# FEATURES -> source 全体を抽出
#   RefSeq RNA においては、source は基本的に1つしかないはずなので、
#   最初にマッチした箇所のみ抽出。2つ目以降は無視される。
	my $source_feature = ($features =~ /
		^(\ {5}source\ .*?)(  # source feature 全体にマッチ
		^(?!\ {6}) |          # 次の項目の開始位置の手前まで
		\Z )                  # または FEATURES の末尾まで
	/smx) ? $1 : '' ;

# FEATURES -> source -> /db_xref="taxon:xxxxx" を抽出
#   Taxonomy ID (taxid)（整数）
	my $taxon = ($source_feature =~ /
		^\ +\/db_xref=\"taxon:(.*?)\"$
	/mx) ? $1 : '' ;
	print "$locus	$taxon\n" if $taxon_op ;  # RefSeq RNA -> Taxonomy ID の対応を出力

# FEATURES -> gene 全体を抽出
#   RefSeq RNA においては、gene は基本的に1つしかないはずなので、
#   最初にパタンマッチした箇所のみ抽出。2つ目以降は無視される。
	my $gene_feature = ($features =~ /
		^(\ {5}gene\ .*?)(  # gene feature 全体にマッチ
		^(?!\ {6}) |        # 次の項目の開始位置の手前まで
		\Z )                # または FEATURES の末尾まで
	/smx) ? $1 : '' ;

# FEATURES -> gene -> /gene="xxxxx" を抽出
#   Gene Symbol
#   ヒトの場合は基本的に HGNC Symbol が記載されている。
#   HGNC Symbol が付与されていないものにも何らかの値が記載されている（例：LOC123456）
	my $symbol = ($gene_feature =~ /
		^\ +\/gene=\"(.*?)\"$
	/mx) ? $1 : '' ;
	print "$locus	$symbol\n" if $symbol_op ;  # RefSeq RNA -> Gene Symbol の対応を出力

# FEATURES -> gene -> /db_xref="GeneID:xxxxx" を抽出
#   Gene ID（整数） NCBI Gene ID, 旧名 Entrez Gene ID
	my $geneid = ($gene_feature =~ /
		^\ +\/db_xref=\"GeneID:(.*?)\"$
	/mx) ? $1 : '' ;
	print "$locus	$geneid\n" if $geneid_op ;  # RefSeq RNA -> Gene ID の対応を出力

# FEATURES -> gene -> /db_xref="HGNC:xxxxx" を抽出
#   HGNC ID（HGNC:整数）
	my $hgnc = ($gene_feature =~ /
		^\ +\/db_xref=\"HGNC:(.*?)\"$
	/mx) ? $1 : '' ;
	print "$locus	$hgnc\n" if $hgnc_op ;  # RefSeq RNA -> HGNC ID の対応を出力

# FEATURES -> gene -> /db_xref="MIM:xxxxx" を抽出
#   MIM number（整数）
#   複数記載されている場合があるため while() ですべてのパタンマッチを抽出。
#   出力オプション未指定の場合は、カンマ区切りの ID リストを作成。
	my $mim_all = '';
	while ($gene_feature =~ /
		^\ +\/db_xref=\"MIM:(.*?)\"$
	/mxg and ($mim_op or $summary_op)){
		my $mim = $1 ;
		print "$locus	$mim\n" if $mim_op ;  # RefSeq RNA -> MIM number の対応を出力
		if ($mim ne '') {
			$mim_all .= ',' . $mim;
		}
	}
	$mim_all =~ s/^,//g;

# FEATURES -> CDS 全体を抽出
#   RefSeq RNA においては、CDS は基本的に1つしかないはずなので、
#   最初にパタンマッチした箇所のみ抽出。2つ目以降は無視される。
	my $cds_feature = ($features =~ /
		^(\ {5}CDS\ .*?)(  # CDS feature の範囲にマッチ
		^(?!\ {6}) |       # 次の項目の開始位置の手前まで
		\Z )               # または FEATURES の末尾まで
	/smx) ? $1 : '' ;

# FEATURES -> CDS -> /protein_id="xxxxx" を抽出
#   Protein ID (RefSeq Protein)
	my $protein_id = ($cds_feature =~ /
		^\ +\/protein_id=\"(.*?)\"$
	/mx) ? $1 : '' ;
	$protein_id =~ s/\.\d+$// ;  # version 情報を削除
	print "$locus	$protein_id\n" if $protein_op ;  # RefSeq RNA -> RefSeq Protein の対応を出力

# FEATURES -> variation 全体を抽出
#   複数記載されているため while() ですべてのパタンマッチを抽出。
#   出力オプション未指定の場合は、カンマ区切りの ID リストを作成。
	my $dbsnp_all = '';
	while ($features =~ /
		^(\ {5}variation\ .*?)(  # variation feature の範囲にマッチ
		^(?!\ {6}) |             # 次の項目の開始位置の手前まで
		\Z )                     # または FEATURES の末尾まで
	/smxg and ($dbsnp_op or $summary_op)){
		my $variation_feature = $1 ;

# FEATURES -> variation -> /db_xref="dbSNP:xxxxx" を抽出
#   dbSNP（整数）
#   ただし dbSNP の ID は、rs整数 と記載するのが一般的なので、
#   rs を付加することにする。
		my $dbsnp = ($variation_feature =~ /
			^\ +\/db_xref=\"dbSNP:(.*?)\"$
		/mx) ? $1 : '' ;
		print "$locus	rs$dbsnp\n" if $dbsnp_op ;  # RefSeq RNA -> dbSNP の対応を出力
		if ($dbsnp ne '') {
			$dbsnp_all .= ',rs' . $dbsnp;
		}
	}
	$dbsnp_all =~ s/^,//g;

# エントリのまとめを1行で出力
	print join "\t", (
		$locus,      # RefSeq RNA accession
		$version,    # RefSeq RNA accession.version
		$taxon,      # Taxonomy ID
		$symbol,     # Gene Symbol
		$geneid,     # Gene ID
		$hgnc,       # HGNC ID
		$protein_id, # RefSeq Protein accession.version
		$mim_all,    # comma separated MIM IDs
		$pubmed_all, # comma separated PubMed IDs
		$dbsnp_all,  # comma separated dbSNP IDs
	), "\n" if $summary_op ;
}

exit ;
