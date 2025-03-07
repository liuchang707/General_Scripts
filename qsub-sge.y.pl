#!/usr/bin/perl

=head1 Name

qsub-sge.pl -- control processes running on linux SGE system

=head1 Description

This program throw the jobs and control them running on linux SGE system. It reads jobs
from an input shell file. One line is the smallest unit of  a single job, however, you can also specify the
number of lines to form a single job. For sequential commands, you'd better put them
onto a single line, seperated by semicolon. In anywhere, "&" will be removed
automatically. The program will terminate when all its jobs are perfectly finished.

If you have so many jobs, the efficency depends on how many CPUs you can get,
or which queque you have chosen by --queue option. You can use the --maxjob option to
limit the number of throwing jobs, in order to leave some CPUs for other people.
When each job consumes long time, you can use the --interval option to increase interval
time for qstat checking , in order to reduce the burden of the head node.

As SGE can only recognize absolute path, so you'd better use absolute path everywhere,
we have developed several ways to deal with path problems:
(1) We have added a function that converting local path to absolute
path automatically. If you like writting absolute path by yourself, then you'd better close this
function by setting "--convert no" option.
(2) Note that for local path, you'd better write
"./me.txt" instead of only "me.txt", because "/" is the  key mark to distinguish path with
other parameters.
(3) If an existed file "me.txt" is put in front of the redirect character ">",
or an un-created file "out.txt" after the redirect character ">",
the program will add a path "./" to the file automatically. This will avoid much
of the problems which caused by forgetting to write "./" before file name.
However, I still advise you to write "./me.txt" instead of just "me.txt", this is a good habit.
(4) Please also note that for the re-direct character ">" and "2>", there must be space characters
both at before and after, this is another good habit.

There are several mechanisms to make sure that all the jobs have been perfectly finished:
(1) We add an auto job completiton mark "This-Work-is-Completed!" to the end of the job, and check it after the job finished
    (for example, "my job complete") to STDERR at the end of your program, and set --secure "my job complete" at
	this program. You'd better do this when you are not sure about wheter there is bug in your program.
(4) We provide a "--reqsub" option, to throw the unfinished jobs automatically, until all the jobs are
    really finished. By default, this option is closed, please set it forcely when needed. The maximum
	reqsub cycle number allowed is 30.
(5) Add a function to detect the died computing nodes automatically.
(6) Add checking "iprscan: failed" for iprscan
(7) Add a function to detect queue status, only "r", "t", and "qw" is considered correct.
(8) Add check "failed receiving gdi request"

Normally, The result of this program contains 3 parts: (Note that the number 24137 is the process Id of this program)
(1) work.sh.24137.globle,     store the shell scripts which has been converted to global path
(2) work.sh.24137.qsub,       store the middle works, such as job script, job STOUT result, and job STDERR result
(3) work.sh.24137.log,      store the error job list, which has been throwed more than one times.

I advice you to always use the --reqsub option and check the .log file after this program is finished. If you find "All jobs finished!", then
then all the jobs have been completed. The other records are the job list failed in each throwing cycle, but
don't worry, they are also completed if you have used --reqsub option.

For the resource requirement, by default, the --resource option is set to vf=1.9G, which means the total
memory restriction of one job is 1.9G. By this way, you can throw 8 jobs in one computing node, because the
total memory restriction of one computing node is 15.5G. If your job exceeds the maximum memory allowed,
then it will be killed forcely. For large jobs, you must specify the --resource option manually, which
has the same format with "qsub -l" option. If you have many small jobs, and want them to run faster, you
also need to specify a smaller memory requirement, then more jobs will be run at the same time. The key
point is that, you should always consider the memory usage of your program, in order to improve the efficency
of the whole cluster.

=head1 Version

  Author: Fan Wei, fanw@genomics.org.cn
  Autor: Hu Yujie  huyj@genomics.org.cn
  Version: 8.2,  Date: 2009-11-11
  Update: YangXianwei Thu Aug 10 14:01:28 CST 2017

=head1 Usage

  perl qsub-sge.pl <jobs.txt>
  --global          only output the global shell, but do not excute
  --queue <str>     specify the queue to use, default all availabile queues
  --P     <str>     Project ID
  --interval <num>  set interval time of checking by qstat, default 300 seconds
  --lines <num>     set number of lines to form a job, default 1
  --maxjob <num>    set the maximum number of jobs to throw out, default 40
  --convert <yes/no>   convert local path to absolute path, default yes
  --secure <mark>   set the user defined job completition mark, default no need
  --reqsub          reqsub the unfinished jobs untill they are finished, default no
  --resource <str>  set the required resource used in qsub -l option, default vf=1.2G
  --jobprefix <str> set the prefix tag for qsubed jobs, default work
  --verbose         output verbose information to screen
  --bash            use /bin/bash to run
  --help            output help information to screen

  --getmem          output the usage (example: cpu=00:26:45, mem=111.63317 GBs, io=0.00000, vmem=259.148M, maxvmem=315.496M);

=head1 Exmple

  1.work with default options (the most simplest way)
  perl qsub-sge.pl ./work.sh

  2.work with user specifed options: (to select queue, set checking interval time, set number of lines in each job, and set number of maxmimun running jobs)
  perl qsub-sge.pl --queue all.q -interval 1 -lines 3 -maxjob 10  ./work.sh

  3.do not convert path because it is already absolute path (Note that errors may happen when convert local path to absolute path automatically)
  perl qsub-sge.pl --convert no ./work.sh

  4.add user defined job completion mark (this can make sure that your program has executed to its last sentence)
  perl qsub-sge.pl -inter 1  -secure "my job finish" ./work.sh

  5.reqsub the unfinished jobs until all jobs are really completed (the maximum allowed reqsub cycle is 50)
  perl qsub-sge.pl --reqsub ./work.sh

  6.work with user defined memory usage
  perl qsub-sge.pl --resource vf=1.9G ./work.sh

  7.recommend combination of usages for common applications (I think this will suit for 99% of all your work)
  perl qsub-sge.pl --queue all.q --resource vf=1.9G -maxjob 10 --reqsub ./work.sh

=cut


use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use File::Path qw(rmtree);
use Cwd qw(abs_path);
use Data::Dumper;

##get options from command line into variables and set default values
my ($Global,$Queue, $Priority, $Interval, $Lines, $Maxjob, $Convert,$Secure,$Reqsub,$Resource,$Job_prefix,$Verbose, $Help, $getmem);
my $Bash;
GetOptions(
        "global"=>\$Global,
        "lines:i"=>\$Lines,
        "maxjob:i"=>\$Maxjob,
        "interval:i"=>\$Interval,
        "queue:s"=>\$Queue,
        "P:s"=>\$Priority,
        "convert:s"=>\$Convert,
        "secure:s"=>\$Secure,
        "reqsub"=>\$Reqsub,
        "resource:s"=>\$Resource,
        "jobprefix:s"=>\$Job_prefix,
        "verbose"=>\$Verbose,
        "bash" => \$Bash,
        "help"=>\$Help,
        "getmem"=>\$getmem,
        );
##$Queue ||= "all.q";
$Interval ||= 300;
$Lines ||= 1;
$Maxjob ||= 40;
$Convert ||= 'yes';
$Resource ||= "vf=1.2G";
$Job_prefix ||= "work";

die `pod2text $0` if (@ARGV == 0 || $Help);

my $work_shell_file = shift;

##global variables
my $work_shell_file_globle = $work_shell_file.".$$.globle";
my $work_shell_file_error = $work_shell_file.".$$.log";
my $Work_dir = $work_shell_file.".$$.qsub";
my $current_dir = abs_path(".");

### get mem ;  add by nixiaoming nixiaoming@genomics.cn
my $work_shell_mem = $work_shell_file.".$$.mem.log";
my %meminfo=();
#open GETMEM,'>',$work_shell_mem or die "can't open the mem info $work_shell_mem ";

my $whoami=`whoami`;
chomp($whoami);

#close GETMEM;
###

if ($Convert =~ /y/i) {
    absolute_path($work_shell_file,$work_shell_file_globle);
}else{
    $work_shell_file_globle = $work_shell_file;
}

if (defined $Global) {
    exit();
}

my $time='`date +%F'."'  '".'%H:%M`';

## read from input file, make the qsub shell files
my $line_mark = 0;
my $Job_mark="00001";
mkdir($Work_dir);
my @Shell;
open IN, $work_shell_file_globle || die "fail open $work_shell_file_globle";
while(<IN>){
    chomp;

    next unless($_);
    next if(/^#/);
    if ($line_mark % $Lines == 0) {
        open OUT,">$Work_dir/$Job_prefix\_$Job_mark.sh" || die "failed creat $Job_prefix\_$Job_mark.sh";
        print OUT 'echo start at time '.$time."\n";
        push @Shell,"$Job_prefix\_$Job_mark.sh";
        $Job_mark++;
    }
    s/[^\\];\s*$//;
    s/;\s*;/;/g;
    print OUT $_.' &&  echo This-Work-is-Completed!'."\n";


    if ($line_mark % $Lines == $Lines - 1) {
        print OUT 'echo finish at time '.$time."\n";
        close OUT;
    }

    $line_mark++;
}
close IN;
if ($line_mark < $Lines) {
    print OUT 'echo finish at time '.$time."\n";
}
close OUT;

print STDERR "make the qsub shell files done\n" if($Verbose);


## run jobs by qsub, until all the jobs are really finished
my $qsub_cycle = 1;
while (@Shell) {
    my %Alljob;
    my %Runjob;
    my %Error;
    chdir($Work_dir);
    my $job_cmd = "qsub -cwd -S /bin/sh ";
    if ( defined($Bash) )
    {
        $job_cmd = "qsub -cwd -S /bin/bash ";
    }
    $job_cmd .= "-q $Queue "  if(defined $Queue);
    $job_cmd .= "-P $Priority " if (defined $Priority);
    my @resources=split /;/,$Resource;
    die "no valid resource\n" if(@resources<1);
    my $part_resource;

    for (my $i=0; $i<@Shell; $i++) {
        while (1) {
            my $run_num = run_count(\%Alljob,\%Runjob,\%meminfo);
            if ( ( $run_num != -1 && $i < $Maxjob ) || ($run_num != -1 && $run_num < $Maxjob) ) {
                if(@resources>0){
                    $part_resource=shift @resources;
                }
                my $jod_return = `$job_cmd -l $part_resource $Shell[$i]`;
                my $job_id = $1 if($jod_return =~ /Your job (\d+)/);
                $Alljob{$job_id} = $Shell[$i];
                print STDERR "throw job $job_id in the $qsub_cycle cycle\n" if($Verbose);	
                last;
            }else{
                print STDERR "wait for throwing next job in the $qsub_cycle cycle\n" if($Verbose);
                sleep $Interval;
            }
        }
    }
    chdir($current_dir);

    while (1) {
        my $run_num = run_count(\%Alljob,\%Runjob,\%meminfo);
        last if($run_num == 0);
        print STDERR "There left $run_num jobs runing in the $qsub_cycle cycle\n" if(defined $Verbose);

        if(defined $getmem){
            open GETMEM,'>',$work_shell_mem or die "can't open the mem info $work_shell_mem ";
            print GETMEM "User:\t\t$whoami\nShellPath:\t$current_dir/$Work_dir\n";
            foreach my $shname (sort keys %meminfo){
                my $jobinfo=$meminfo{$shname};
                chomp $jobinfo;
                $jobinfo =~ s/usage\s*\w*:\s*//g;
                print GETMEM "$whoami\t$shname\t$jobinfo\n";
            }
            close GETMEM;
        }

        sleep $Interval;
    }

    print STDERR "All jobs finished, in the firt cycle in the $qsub_cycle cycle\n" if($Verbose);
    open OUT, ">>$work_shell_file_error" || die "fail create $$work_shell_file_error";
    chdir($Work_dir);
    foreach my $job_id (sort keys %Alljob) {
        my $shell_file = $Alljob{$job_id};
        my $content;
        if (-f "$shell_file.o$job_id") {
            $content = `tail -n 1000 $shell_file.o$job_id`;
        }

        if ($content !~ /This-Work-is-Completed!/ || $content !~ /finish at time/) {
            $Error{$job_id} = $shell_file;
            print OUT "In qsub cycle $qsub_cycle, In $shell_file.o$job_id,  \"This-Work-is-Completed!\" is not found, so this work may be unfinished\n";
        }

        my $content;
        if (-f "$shell_file.e$job_id") {
            $content = `tail  -n 1000 $shell_file.e$job_id`;
        }

        if (defined $Secure && $content !~ /$Secure/) {
            $Error{$job_id} = $shell_file;
            print OUT "In qsub cycle $qsub_cycle, In $shell_file.o$job_id,  \"$Secure\" is not found, so this work may be unfinished\n";
        }
    }

    @Shell = ();
    foreach my $job_id (sort keys %Error) {
        my $shell_file = $Error{$job_id};
        push @Shell,$shell_file;
    }

    $qsub_cycle++;
    if($qsub_cycle > 30){
        print OUT "\n\nProgram stopped because the reqsub cycle number has reached 10, the following jobs unfinished:\n";
        foreach my $job_id (sort keys %Error) {
            my $shell_file = $Error{$job_id};
            print OUT $shell_file."\n";
        }
        print OUT "Please check carefully for what errors happen, and redo the work, good luck!";
        die "\nProgram stopped because the reqsub cycle number has reached 30\n";
    }

    print OUT "All jobs finished!\n" unless(@Shell);

    chdir($current_dir);
    close OUT;
    print STDERR "The secure mechanism is performed in the $qsub_cycle cycle\n" if($Verbose);

    last unless(defined $Reqsub);
}

if(defined $getmem){
    open GETMEM,'>',$work_shell_mem or die "can't open the mem info $work_shell_mem ";
    print GETMEM "User:\t\t$whoami\nShellPath:\t$current_dir/$Work_dir\n";
    foreach my $shname (sort keys %meminfo){
        my $jobinfo=$meminfo{$shname};
        chomp $jobinfo;
        $jobinfo =~ s/usage\s*\w*:\s*//g;
        print GETMEM "$whoami\t$shname\t$jobinfo\n";
    }
    close GETMEM;
}

print STDERR "\nqsub-sge.pl finished\n" if($Verbose);


####################################################
################### Sub Routines
####################################################

sub absolute_path{
    my($in_file,$out_file)=@_;
    my($current_path,$shell_absolute_path);


    $current_path=abs_path(".");


    if ($in_file=~/([^\/]+)$/) {
        my $shell_local_path=$`;
        if ($in_file=~/^\//) {
            $shell_absolute_path = $shell_local_path;
    }
        else{$shell_absolute_path="$current_path"."/"."$shell_local_path";}
    }


    open (IN,"$in_file");
    open (OUT,">$out_file");
    while (<IN>) {
        chomp;


        my @words=split /\s+/, $_;


        for (my $i=1; $i<@words; $i++) {
            if ($words[$i] !~ /\//) {
                if (-f $words[$i]) {
                    $words[$i] = "./$words[$i]";
                }elsif($words[$i-1] eq ">" || $words[$i-1] eq "2>"){
                    $words[$i] = "./$words[$i]";
                }
        }

        }
        for (my $i=0;$i<@words ;$i++) {
            if (($words[$i]!~/^\//) && ($words[$i]=~/\//)) {
                $words[$i]= "$shell_absolute_path"."$words[$i]";
        }
        }
        print OUT join("  ", @words), "\n";
    }
    close IN;
    close OUT;
}


##get the IDs and count the number of running jobs
##the All job list and user id are used to make sure that the job id belongs to this program
##add a function to detect jobs on the died computing nodes.
sub run_count {
    my $all_p = shift;
    my $run_p = shift;
    my $memlist = shift;
    my $run_num = 0;

    %$run_p = ();
#    my $user = $ENV{"USER"} || $ENV{"USERNAME"};
#    $user = substr($user, 0, 12);
    chomp(my $user = `whoami`);
    my $qstat_result = `qstat -u $user 2>&1`;
    $user = substr($user,0,12);
    if ($qstat_result =~ /failed receiving gdi request/) {
        print STDERR "$qstat_result";
        $run_num = -1;
        return $run_num;
    }
    if ($qstat_result =~ /unable to contact qmaster/) {
        print STDERR "$qstat_result";
        $run_num = -1;
        return $run_num;
    }
    my @jobs = split /\n/,$qstat_result;
    my %died;
    died_nodes(\%died) if (@jobs > 0);
    foreach my $job_line (@jobs) {
        $job_line =~s/^\s+//;
        my @job_field = split /\s+/,$job_line;
        next if($job_field[3] ne $user);
        if (exists $all_p->{$job_field[0]}){
            my $node_name = $1 if($job_field[7] =~ /(compute-\d+-\d+)/);
            if ( !exists $died{$node_name} && ($job_field[4] eq "qw" || $job_field[4] eq "r" || $job_field[4] eq "t") ) {
                $run_p->{$job_field[0]} = $job_field[2];
                $run_num++;
                if ((defined $getmem) && ($job_field[4] eq "r")){### get mem ;  add by nixiaoming nixiaoming@genomics.cn
                    my $jobinfo=`qstat -j $job_field[0] 2>&1 |grep usage `;
                    $$memlist{$all_p->{$job_field[0]}}=$jobinfo;
                }
            }else{
                `qdel $job_field[0]`;
            }
        }
    }

    return $run_num;
}


##HOSTNAME                ARCH         NCPU  LOAD  MEMTOT  MEMUSE  SWAPTO  SWAPUS
##compute-0-24 lx26-amd64 8 - 15.6G - 996.2M -
sub died_nodes{
    my $died_p = shift;

    my @lines = split /\n/,`qhost`;
    shift @lines for (1 .. 3);

    foreach  (@lines) {
        my @t = split /\s+/;
        my $node_name = $t[0];
        my $memory_use = $t[5];
        $died_p->{$node_name} = 1 if($t[3]=~/-/ || $t[4]=~/-/ || $t[5]=~/-/ || $t[6]=~/-/ || $t[7]=~/-/);
    }

}
#  --priority <str>  the option allows users to designate the relative priority of a batch job for selection from a queue, such as bc_phar
