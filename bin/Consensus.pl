#!/usr/bin/perl

my %hashAssign = ();

while($line = <STDIN>){
    chomp($line);

    my @tokens = split(/,/,$line);
    
    if($tokens[0]=~/(.*)\.(.*)/){
        $hashAssign{$1}{$tokens[1]}++;
    }
    else{
        print "$tokens[0],$tokens[1]\n";
    }
}

foreach $key(keys %hashAssign){
    my $ftotal = 0;
    my $max = 0;
    my $maxC = -1;
    foreach $clust(keys %{$hashAssign{$key}}){
        my $f = $hashAssign{$key}{$clust};
        $ftotal += $f;
        if($f > $max){
            $max = $f;
            $maxC = $clust;
        }
    }
    print "$key,$maxC\n";
}


