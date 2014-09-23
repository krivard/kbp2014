#!/usr/bin/perl

my $feature=shift;
my $cookedFile=shift;
my $keyFile=shift;
defined($keyFile) or die "Usage:\n\tfeature trainOrTest.examples.cooked trainOrTest.examples.graphKey > trainOrTest.edges.$$feature.txt\n";

open(my $cF,"<$cookedFile") or die "Couldn't open file $cookedFile for reading:\n$!\n";
open(my $kF,"<$keyFile") or die "Couldn't open key file $keyFile for reading:\n$!\n";

my $c=0;
my $k=0;
my $kcache=<$kF> or die "End of key file reached before I could even get started\n";
$kcache =~ s/-[0-9][0-9]*/_/;
while(<$cF>) {
    chomp;
    $c++;
    my @searchedges; # from query -> (src,dest)
    my $ne=0;
    $_=~s/-[0-9][0-9]*/_/;
    my ($query,$foo2,$foo3,$foo4,$foo5,$foo6,$featurestr,@edges) = split("\t");
    my @features = split(":",$featurestr);
    
    my $searchi = -1;
    for (my $fi = 0; $fi < @features; $fi++) {
	if ($features[$fi] eq $feature) { $searchi = $fi; last; }
    }
    if ($searchi >= 0) {
	foreach my $e (@edges) {
	    my @foo = split(":",$e);
	    my @bar = split("->",$foo[0]);
	    foreach my $f ( split(",", $foo[1]) ) {
		if ($f == $searchi) {
		    push(@searchedges, \@bar);
		    $ne ++;
		    last;
		}
	    }
	}
	#print "$ne edges retrieved at line $c of cooked file for query $query\n";
    }
    
    $ne=0;
    my @nodeNames;
    while(1) {
	my $key = $kcache;
	$k++;
	chomp($key);
	my ($kquery,$nodeid,$name) = split("\t",$key);
	($kquery eq $query) or die "Mismatch between line $c of cooked file and line $k of key file:\n$query\n$kquery\n";
	#print "$k: $nodeid -> $name\n";
	$nodeNames[$nodeid] = $name;
	$ne++;
	#print "$k: $kcache";
	
	# preload next line:
	last unless ($kcache = <$kF>);
	$kcache =~ s/-[0-9][0-9]*/_/;
	#print "\t$k+1: $kcache";
	chomp($kcache);
	($kquery,$nodeid,$name) = split("\t",$kcache);
	#my $yes="keep going";
	#$yes="stop" if ($kquery ne $query);
	#print "\t$k+1: $yes\n";
	last if ($kquery ne $query);
    } 
    #print "$ne node names retrieved at line $k of key file\n";

    $ne=0;
    foreach my $e_ref (@searchedges) {
	#print "$e_ref\n";
	my $src = $nodeNames[$e_ref->[0]];#split("...",$nodeNames[$e_ref->[0]]);
	my $dst = $nodeNames[$e_ref->[1]];#split("...",$nodeNames[$e_ref->[1]]);
	$src=~s/.*\.\.\.//;
	$dst=~s/.*\.\.\.//;
	print "$query\n\t$src\t$dst\n";#\t$src[1]\t$dst[1]\n";
	$ne++;
    }
    #print "$ne edges decoded\n";
}

close($cF);
close($kF);
