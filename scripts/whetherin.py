#!/usr/env/python
import sys
import re
if len(sys.argv)<4:
	print("<complete and singlecopy list > <your missing and fragment list> <outfile>")
infile1=sys.argv[1]
infile2=sys.argv[2]
#outfile=sys.argv[3]
in1=open(infile1,'r')
in2=open(infile2,'r')
#out=open(outfile,'w')
name={}
for line in in1:
	line=line.strip()
	n=line.split('\t')[0]
	name[n]=1
	#print (n)
count=0
for line in in2:
    if not re.search('^#',line):
            line=line.strip()
            n=line.split()[0]
            if n in name:
                count+=1
print (count)
"""
for line in in2:
	line=line.strip()
	n=line.split('\t')[0].split('>')[1]
	if n  in name:
		count+=1
		out.write(line+'\n')
print (count)
"""
in1.close()
in2.close()
