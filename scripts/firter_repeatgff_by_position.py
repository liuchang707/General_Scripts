#!/usr/env/python
import re
import sys
oldgff=open(sys.argv[1])
newgff=open(sys.argv[1].strip()+'.norepeat.gff','w')
switch=0
g={}

for line in oldgff:
    l=line
    line=line.strip().split()
    a=line[0]+'_'+line[3]+'_'+line[4]+'_'+line[6]
    if line[2] == 'mRNA':
        if a not in g:
            g[a]=1
            newgff.write(l)
            switch=1
        else:
            switch=0
    else:
        if switch==1:
            newgff.write(l)


oldgff.close()
newgff.close()



