#!/usr/env/python
import re
import sys
oldgff=open(sys.argv[1])
position=open(sys.argv[2])
newgff=open(sys.argv[3],'w')
switch=0
g={}
for line in position:
    pos=line.strip().split('\t')[0]+'_'+line.strip().split('\t')[1]+'_'+line.strip().split('\t')[2]
    g[pos]=1

for line in oldgff:
    l=line
    line=line.strip().split()
    a=line[0]+'_'+line[3]+'_'+line[4]
    if line[2] == 'mRNA':
        if a not in g:
            newgff.write(l)
            switch=1
        else:
            switch=0
    else:
        if switch==1:
            newgff.write(l)


oldgff.close()
position.close()
newgff.close()



