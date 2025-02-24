#!/usr/env/python
import re
import sys

if len(sys.argv)<2 :
    print("Usage: python "+sys.argv[0]+" fasta_file")
    exit()
file=open(sys.argv[1],'r')
total=0
N=0
for line in file:
    if re.search('>',line) :
        continue
    line=line.strip()
    total+=len(line)
    line=line.upper()
    N+=line.count('N')

print ('Total: '+str(total))
print ('N|n_num: '+str(N) )
proportion=N/total
print ('N|n_num / Total = %.3f' % proportion )
