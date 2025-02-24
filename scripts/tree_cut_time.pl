my $file = $ARGV[0];
open IN,$file or die $!;
while(<IN>){
	my $word = $_;
	chomp($word);
	$word =~ s/:\d+\.\d+//g;
	$word =~ s/\s+//g;
	print $word;
}
