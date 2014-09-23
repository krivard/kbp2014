#!/usr/bin/perl

my $queryNames = shift;
my $entityNames = shift;
my $gold = shift;
my $solutions = shift;

defined($solutions) or die "Usage:\n\t queryName_qid_name.cfacts entityName_name_eid.cfacts kbp_X.gold_solutions.txt kbp_X.solutions.txt > kbp_X.hr.solutions.txt";

open(my $QF, "<$queryNames") or die "Couldn't open query names file $queryNames:\n$!\n";
open(my $EF,"<$entityNames") or die "Couldn't open entity names file $entityNames:\n$!\n";
open(my $GF,"<$gold") or die "Couldn't open gold solutions file $gold:\n$!\n";
open(my $SF,"<$solutions") or die "Couldn't open solutions file $solutions:\n$!\n";

my %qn;
while(<$QF>) {
    chomp;
    my ($foo, $qid, $name) = split "\t";
    $qn{$qid} = $name;
}
close($QF);

my %en;
while(<$EF>) {
    chomp;
    my ($foo, $name, $eid) = split "\t";
    $en{"$eid"} = $name;
}
close($EF);

my %g;
while(<$GF>) {
    chomp;
    my ($qid,$eid) = split "\t";
    $g{$qid} = $eid;
}

while(<$SF>) {
    chomp;
    if (/^#/) {
	my ($pre, $qid, $post) = split ",";
	print "$pre,$qn{$qid},$post\n";
	print "G\t1.0\t-1=$g{$qid}:$en{$g{$qid}}\n";
    } else {
	my ($pre, $eid) = split "c";
	$eid=~s/[[]//;
	$eid=~s/[]]//;
	print "$pre$eid:$en{$eid}\n";
    }
}
close($SF);
