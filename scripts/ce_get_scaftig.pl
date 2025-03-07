#!/usr/bin/perl -w
#
#Author: Ruan Jue <ruanjue@genomics.org.cn>
#
use warnings;
use strict;

if (@ARGV < 1 ) {
	print "usage: perl script.pl  <scafold> > scaf.contig \n";
	exit
}
my $min_length = 10;
my $name;
my $seq;

while(<>){
   if(/^>(\S+)/){
      &print_scafftig($name, $seq) if($seq);
      $name = $1;
      $seq  = '';
   } else {
      chomp;
      $seq .= $_;
   }
}
&print_scafftig($name, $seq) if($seq);


sub print_scafftig {
   my $name = shift;
   my $seq  = shift;
   my $temp = $seq;
   my $id = 1;
   my $flag = 0;
   my $pos = 1;
   while($seq=~/([ATGCatgc]+)/g){
   my $s = $1;
   if($flag==1){
      if($temp=~/([ATGCatgc]+[Nn]+)/g){
         my $g = $1;
         $pos+=length($g);
      }
   }
   else{$flag=1;}
   next if(length($s) < $min_length);
   print ">$name\_$id  start=$pos  length=".length($s)."\n";
   while($s=~/(.{1,8})/g){
      print "$1\n";
   }
   $id++;
}
}
