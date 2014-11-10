#!/usr/bin/perl

my $SKIP=0,$SEARCH=1,$MATCH=2;
my $query="";
my $soln="nil";
my $state=$SKIP;
my $top="";
my $ntop=0;

while(<>) {
    chomp;
    my ($qid,$did,$rank,$score,$eid,$xtype,$ntype) = split "\t";
    if ($state == $SKIP) {
	next unless ($qid ne $query);
	$state = $SEARCH;
	$query = $qid;
	$top = $_;
    }
    if ($qid ne $query) {
	$ntop++;
	print "$top\tFALLBACK\n";
	$state = $SEARCH;
	$query = $qid;
	$top = $_;
    }
    if ($state == $SEARCH) {
	next if ($eid eq "nil");
	$top = $_;
	$state = $MATCH;
    }
    if ($state == $MATCH) {
	next unless ( 
	    ($xtype eq $ntype) or
	    ( ($xtype eq "na") and ($ntype =~ /org|per|gpe/) )
	    );
	print "$_\n";
	$state = $SKIP;
    }
}

if ($state != $SKIP) { print "$top\tFALLBACK\n"; $ntop++; }
print STDERR "$ntop queries used fallback solution\n";
