#!/usr/bin/perl -w
use strict;
####edit by chenlei


open IN,$ARGV[0] || die "perl $0 <input> > [output]\n";
#open OUT,">$ARGV[1]" || die "$!\n";

$/=">";<IN>;$/="\n";
#my $all_len=0;
my $total_lenth;my $total_low;
while (<IN>){
	my $id=$1 if (/^(\S+)/);
	$/='>';
	my $seq=<IN>;
	chomp($seq);
	$seq=~s/\s//g;
	my $nu=$seq=~tr/atcg/atcg/;
	my $len=length($seq);

	#print "$id\t$len\n";

#	$all_len +=$len;

	$total_lenth+=$len;
	$total_low+=$nu;
	$/="\n";
}
close IN;

my $ratio = $total_low/$total_lenth;
print "Total_bases:$total_lenth\n";
print "Small_bases:$total_low\n";
print "mask_ratio:$ratio\n";
#print "$all_len\n";
#print OUT "$all_len\n";
#close OUT;

