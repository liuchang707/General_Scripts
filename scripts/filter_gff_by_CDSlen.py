#!/usr/env/python
import re
import sys
oldgff=sys.argv[1]
newgff=sys.argv[2]
length=sys.argv[3]
switch=0

IN=open(oldgff,'r')
OUT=open(newgff,'w')
rnaandgene=''
cds=''
cdslen=0
for line in IN:
	a=line.split('\t')
	if a[2] == 'gene':
		if cdslen>=int(length):
			OUT.write(rnaandgene+cds)
		rnaandgene=''
		cds=''
		cdslen=0
		rnaandgene=line
	elif a[2] !='CDS':
		rnaandgene+=line
	else:
		cdslen+=int(a[4])-int(a[3])+1
		cds+=line

if cdslen>=int(length):
	OUT.write(rnaandgene+cds)

IN.close()
OUT.close()

