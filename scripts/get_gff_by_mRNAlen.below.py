#!/usr/env/python
import re
import sys
oldgff=sys.argv[1]
newgff=sys.argv[2]
length=sys.argv[3]
switch=0

IN=open(oldgff,'r')
OUT=open(newgff,'w')

for line in IN:
	line=line.strip()
	a=line.split('\t')
	if a[2] == 'mRNA':
		if (int(a[4])-int(a[3]))<=int(length):
			OUT.write(line+'\n')
			switch=1
		else:
			switch=0
	else:
		if switch==1:
			OUT.write(line+'\n')
IN.close()
OUT.close()



