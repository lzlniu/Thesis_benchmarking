#!/usr/bin/perl -w

use strict;
use POSIX;

# changes: 
# 1. mathematics correct rounding 
# 2. decrease bin size
# 3. variable names and comments
# 4. initiation of 20th and 40th percentile

# factor for bin size. The larger, the smaller the bins
my $BINFACTOR = 200;

# read in entities file
my %serial_type = ();
my %serial_type_identifier = ();
open IN, "< /home/projects/ku_10024/data/dictionary/all_entities.tsv";
while (<IN>) {
	s/\r?\n//;
	my ($serial, $type, $identifier) = split /\t/;
	$serial_type{$serial} = $type;
	$serial_type_identifier{$serial} = $type."\t".$identifier;
}
close IN;

# raw textmining scores
open IN, "< new_all_pairs.tsv";
open OUT, "> new_database_pairs_orig.tsv";
while (<IN>) {
	s/\r?\n//;
	my ($serial1, $serial2, $raw_score, undef) = split /\t/;
	next unless exists $serial_type_identifier{$serial1} and exists $serial_type_identifier{$serial2};
	my $type1 = $serial_type{$serial1};
	my $type2 = $serial_type{$serial2};
	my $types;
	if ($type1 <= $type2) {
		$types = $type1."\t".$type2;
	}
	else {
		$types = $type2."\t".$type1;
	}
	print OUT $serial_type_identifier{$serial1}, "\t", $serial_type_identifier{$serial2}, "\t", $raw_score, "\n";
	print OUT $serial_type_identifier{$serial2}, "\t", $serial_type_identifier{$serial1}, "\t", $raw_score, "\n";
}
close IN;
close OUT;

close STDERR;
close STDOUT;
POSIX::_exit(0);
