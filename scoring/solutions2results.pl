#!/usr/bin/perl

my $query="";
my $soln="nil";
my $threshold=shift;
$threshold = 0.0 unless defined($threshold);
#print "THRESHOLD=$threshold\n";
while(<>) {
    chomp;
    if (/^#/) {
	my ($cruft,$q) = split ",";
	if ($query ne "") {
	    print "$query\t$soln\n";
	}
	$query = $q;
	$soln="nil";
    } elsif (/^[12]\s/) {
	chop;
	my ($cruft, $c, $cruft) = split "\t";
	my ($cruft, $s) = split "\\[";
	if ($soln eq "nil") {
	    if ($c > $threshold) {
		$soln = $s;
	    }
	    # print "c: $c  s: $s  soln: $soln\n";
	}
    }
}
print "$query\t$soln\n";
