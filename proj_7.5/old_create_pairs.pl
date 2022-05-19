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

# bin textmining scores from tagger results
my %types_score_count = ();
open IN, "< old_all_pairs.tsv";
while (<IN>) {
	s/\r?\n//;
	my ($serial1, $serial2, $raw_score, undef) = split /\t/;
	next unless exists $serial_type{$serial1} and exists $serial_type{$serial2};
	# map serial ID to type
	my $type1 = $serial_type{$serial1};
	my $type2 = $serial_type{$serial2};
	my $types;
	if ($type1 <= $type2) {
		$types = $type1."\t".$type2;
	}
	else {
		$types = $type2."\t".$type1;
	}
	# calculate score from raw textmining score
	# scores are binned by rounding to integers
	my $score = sprintf('%.0f', 10*$BINFACTOR*log($raw_score)/log(2));
	# avoid extremely large or small numbers
	$score = -20*$BINFACTOR if $score < -20*$BINFACTOR;
	$score = 50*$BINFACTOR if $score > 50*$BINFACTOR;
	# create hash with count of scores
	if (exists $types_score_count{$types} and exists $types_score_count{$types}{$score}) {
		$types_score_count{$types}{$score}++;
	}
	else {
		$types_score_count{$types}{$score} = 1;
	}
}
close IN;

# calculate mean and standard deviation for calculation of Z-scores
# 20th and 40th percentile used as first and second quartile instead of 25th and 
# 50th because we expect a tail on the right hand side and only the lower half 
# to be normal distributed
my %types_mean = ();
my %types_stddev = ();
foreach my $types (keys %types_score_count) {
	# count total number of scores/interactions
	my $total = 0;
	foreach my $count (values %{$types_score_count{$types}}) {
		$total += $count;
	}
	# sort unique scores in increasing order
	my @scores = sort {$a <=> $b} keys %{$types_score_count{$types}};
	# check if at least 2 bins/different scores exist
	next unless scalar @scores >= 2;
	my $cumul = 0;
	# assign first score to 20th and 40th percentile
	my $score20 = $scores[0];
	my $score40 = $scores[0];
	# iterate over unique sorted scores
	foreach my $score (@scores) {
		# keep track of the number of scores in the bins
		$cumul += $types_score_count{$types}{$score};
		if ($cumul < 0.2*$total) {
			$score20 = $score;
		}
		elsif ($cumul < 0.4*$total) {
			$score40 = $score;
		}
		else {
			last;
		}
	}
	$types_mean{$types} = $score40;
	# calculate standard deviation based on first and second quartile
	$types_stddev{$types} = ($score40-$score20)/0.67;
}

# convert raw textmining scores in Z-scores
open IN, "< old_all_pairs.tsv";
open OUT, "> old_database_pairs.tsv";
while (<IN>) {
	s/\r?\n//;
	my ($serial1, $serial2, $score, undef) = split /\t/;
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
	# discard pairs for which the standard deviation could not be calculated
	next unless exists $types_mean{$types} and exists $types_stddev{$types} and $types_stddev{$types}>0;
	# calculate Z-score
	my $evidence = (10*$BINFACTOR*log($score)/log(2)-$types_mean{$types})/$types_stddev{$types};
	# only keep confident interactions
	next unless $evidence >= 1;
	# calculate star score
	my $star_score = $evidence/2;
	$star_score = 4 if $star_score > 4;
	print OUT $serial_type_identifier{$serial1}, "\t", $serial_type_identifier{$serial2}, "\t", $evidence, "\t", $star_score, "\n";
	print OUT $serial_type_identifier{$serial2}, "\t", $serial_type_identifier{$serial1}, "\t", $evidence, "\t", $star_score, "\n";
}
close IN;
close OUT;

close STDERR;
close STDOUT;
POSIX::_exit(0);
