#! /usr/bin/perl
use strict;

my $seq_fa = shift;
#my $length_cut = shift;
my $length_file = shift;

my($seq_id,$Seq,$len,$key1,$key2);
my %hash;

open(F,$seq_fa) or die;
open(N,">$length_file") or die;
$/=">";<F>;$/="\n";

while(<F>)
{
	chomp;
	/\S+/;
	$seq_id=$&;
	$/=">";
	$Seq=<F>;
	chomp $Seq;
	$/="\n";
	$Seq=~s/\n//g;
	#$Seq=~s/X//g;
	$Seq=~s/N//g;
	$len=length$Seq;
	#print N "$seq_id\t$len\n";
	#next if ($len >$length_cut);
	print N ">$seq_id\t$len\n";
}
close N;
close F;
