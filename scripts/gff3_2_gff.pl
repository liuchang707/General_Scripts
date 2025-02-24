#!/usr/bin/perl
use strict;
open IN,@ARGV[0] || die $!;
open OUT,">@ARGV[1]" || die $!;
my $namec;
while(<IN>){
chomp;
my @info=split(/\t/);
my $name;
if($info[2] eq "mRNA"){
 $name=$1 if ($info[8]=~/ID=(\S+);Parent=/);
 print OUT "$info[0]\t$info[1]\t$info[2]\t$info[3]\t$info[4]\t$info[5]\t$info[6]\t$info[7]\tID=$name;\n";
 $namec=$name;
 }
 if($info[2] eq "CDS"){
 print OUT "$info[0]\t$info[1]\t$info[2]\t$info[3]\t$info[4]\t$info[5]\t$info[6]\t$info[7]\tParent=$namec;\n";
 }
 }
 close IN;
 close OUT;
