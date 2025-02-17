#!/usr/bin/perl
use strict;
die "Usage: perl $0 <fasta_file> <out_file>" if (@ARGV!=2);
$a=shift;
$b=shift;
open A,"$a";
open O,">$b";
$/=">";
<A>;
$/="\n";
my $N=0;my $tot=0;
while (<A>){
		my $title = $_;
		my $seq_name = $1 if($title =~ /^(\S+)/);
		$/=">";
		my $seq=<A>;
		chomp $seq;
		$/="\n";
		$seq=~s/\s//g;
        $tot+=length($seq);
		my $n;
		$n=$seq=~ s/N/N/ig ;
		$N+=$n;
#		print "$seq_name\tN length:$n\n";
}

print O"total length:$tot\nN length:$N\n";


