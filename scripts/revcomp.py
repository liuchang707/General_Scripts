#!/usr/env/python

import re
import sys
import os
inf=open(sys.argv[1])
out=open(sys.argv[1]+'.revcomp','w')

for line in inf:
	line=line.strip()
	if re.search('>',line):
		out.write(line+'\n')
	else:
		line=line.lower()
		a=line.replace('a','T').replace('t','A').replace('c','G').replace('g','C')
		out.write(a[::-1]+'\n')

inf.close()
out.close()
