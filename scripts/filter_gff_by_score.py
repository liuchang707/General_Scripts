#!/usr/env/python
import re
import sys
oldgff=sys.argv[1]
newgff=sys.argv[2]
score=sys.argv[3]
switch=0

IN=open(oldgff,'r')
OUT=open(newgff,'w')

for line in IN:
	line=line.strip()
	a=line.split('\t')
	if a[2] == 'mRNA':
		if float(a[5])>int(score):
			OUT.write(line+'\n')
			switch=1
		else:
			switch=0
	else:
		if switch==1:
			OUT.write(line+'\n')
IN.close()
OUT.close()



