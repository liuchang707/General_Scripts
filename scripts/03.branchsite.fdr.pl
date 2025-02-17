use strict;
use warnings;

my $in="All.branchsite.result.chi2.out.new";
my $out="All.branchsite.result.chi2.fdr.out";
my $outr="$out.R";

my %p;
my %all;
my $linenum=0;
open (O,">$outr");
open (F,"$in");
while(<F>){
    chomp;
    my @a=split(/\s+/,$_);
    if (/^cluster/){
        $a[8]=$a[7];
        $a[7]="fdr";
        my $outline=join("\t",@a);
        print O "library(\"qvalue\")\nwrite.table(\"$outline\",file=\"$out\",append = FALSE,row.names=FALSE,col.names=FALSE,quote = FALSE)\n\n";
    }else{
        $all{$a[1]}{$linenum}=$_;
        $p{$a[1]}{$linenum}=$a[6];
        $linenum++;
    }
}
close F;

for my $sp (sort keys %p){
    my @p;
    my @pk=sort{$a<=>$b} keys %{$p{$sp}};
    for my $pk (@pk){
	#print("$pk\t$p{$sp}{$pk}\n");
        push @p,$p{$sp}{$pk};
    }
    print O "a=read.table('$in',head=T)\n";
    print O "q=qvalue(a\$P_value,pi0.method=\"bootstrap\")\n\n";#,n=length(pvalues))\n\n";
    my $j=0;
    for my $i (@pk){
        $j++;
        my @outline=split(/\t/,$all{$sp}{$i});
        my $last=pop @outline;
        my $first=join("\t",@outline);
        print O "line=paste(\"$first\t\",q\$qvalues[$j],\"\t\",\"$last\")\n";
        print O "write.table(line,file=\"$out\",append = TRUE,row.names=FALSE,col.names=FALSE,quote = FALSE)\n\n";
    }
}
close O;
