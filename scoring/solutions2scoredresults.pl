#!/usr/bin/perl

my $query="";
my $soln="nil";
my $score="1.0";
my $threshold=shift;
$threshold = 0.0 unless defined($threshold);
while(<>) {
    chomp;
    if (/^#/) {
	my ($cruft,$q) = split ",";
	if ($query ne "") {
	    print "$query\t$score\t$soln\n";
	}
	$query = $q;
	$soln="nil";
    } elsif (/^[12]\s/) {
	chop;
	my ($cruft, $c,$cruft) = split "\t";
	my ($cruft,$s) = split "\\[";
	if ($soln eq "nil") {
	    if ($c > $threshold) {
		$soln = $s;
		$score = $c;
	    } else {
		$score = 1-$c;
	    }
	}
    }
}
print "$query\t$score\t$soln\n";
