#!/usr/env/python
import re
import sys
oldgff=open(sys.argv[1])
geneid=open(sys.argv[2])
newgff=open(sys.argv[3],'w')

g={}
for line in geneid:
    gene=line.strip().split('\t')[0]
    g[gene]=1

for line in oldgff:
    l=line
    a=line.strip().split('\t')[8].split(';')[0].split('=')[1]
    if a in g:
        newgff.write(l)
oldgff.close()
newgff.close()
geneid.close()



