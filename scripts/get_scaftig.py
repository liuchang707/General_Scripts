#!/usr/env/python
#
#Author: Ruan Jue <ruanjue@genomics.org.cn>
#
import re
import sys

if (len(sys.argv) < 2) :
	print ('usage:\n python '+ sys.argv[0] +' <scafold> > scaf.contig ')
	exit()
min_length = 100
name=''
seq=''
f=open(sys.argv[1],'r')

def print_scafftig(name,seq):
   i = 1
   b=re.finditer('[ATGCatgc]+',seq)
   for match in b:
       st=match.span()[0]+1
       lengt=len(match.group())
       if lengt>=min_length :
            print (">"+name+"_"+str(i)+"  start="+str(st)+"  length="+str(lengt))
            c=re.finditer('.{1,60}',match.group())
            for matc in c:
                print (matc.group())
            i+=1
       else: next

for line in f:
    if re.search('^>(\S+)',line):
        if len(seq)>0 : print_scafftig(name,seq)
        a=re.search('^>(\S+)',line)
        name = a.group(1)
        seq  = ''
    else :
        line=line.strip()
        seq=seq+line

if len(seq)>0 : print_scafftig(name,seq)
