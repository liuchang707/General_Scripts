#! /usr/bin/perl
use strict;

my $seq_fa = shift;
my $name = shift;
my $out_file = shift;

my($seq_id,$Seq,$Name,$key1,$key2);
my %hash;

open(F,$seq_fa) or die;
open(NAME,$name) or die;
while(<NAME>){
	chomp;
	my$n=(split /\s+/,$_)[0];
	#my$n=(split /\./,(split /\s+/,$_)[0])[1];
	$hash{$n}=1;
    print "$n\n";
}
open(N,">>$out_file") or die;
$/=">";<F>;$/="\n";

while(<F>)
{
	chomp;
	/\S+/;
	$seq_id=$_;
	#$seq_id=$&;
	#print "$seq_id\n";
	my$first=(split /\s+/,$seq_id)[0];
	#my$first=(split /\|/,$seq_id)[1];
	#my$first=(split /\./,(split /\s+/,$_)[0])[1];
	#print $first;
	$/=">";
	$Seq=<F>;
	chomp $Seq;
	$/="\n";
	#$Seq=~s/\n//g;
	#print N "$seq_id\t$len\n";
	next if (!exists $hash{$first})  ;
	print N ">$seq_id\n$Seq\n";
}
close N;
close F;
close NAME;
