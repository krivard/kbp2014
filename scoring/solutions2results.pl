#!/usr/bin/perl

my $query="";
my $soln="nil";
my $threshold=shift;
my $extFilename = shift;
my $entFilename = shift;
defined($entFilename) or die ("Usage:\n\tthreshold extractedType.cfacts entityType.cfacts dataset.solutions.txt > query_soln.txt\n");

open(my $XF,"<$extFilename") or die "Couldn't open extracted types file $extFilename:\n$!\n";
open(my $NF,"<$entFilename") or die "Couldn't open entity types file $entFilename:\n$!\n";



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
