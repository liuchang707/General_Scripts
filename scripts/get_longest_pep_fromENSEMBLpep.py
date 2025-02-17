#!/usr/env/python
import re
import sys
oldpep=open(sys.argv[1])
newpep=open(sys.argv[1].strip()+'.longest.fa','w')
pepname=''
db={}
name={}
n=''
for line in oldpep:
    l=line
    line=line.strip().split()
    if re.search('>',line[0]):
        gene=line[3].split(':')[1]
        pep=line[0].split('>')[1]
        if re.search('gene_symbol:(.*) ',l):
            a=re.search('gene_symbol:(\S+) ',l)
            n=a.group(1)
            #print (gene+'\t'+n)
        if gene not in db:
            db.update({gene:{}})
            db[gene][pep]='' 
            pepname=pep
            if len(n)>1:
                name.update({gene:n})
            n=''
        else:
            db[gene][pep]=''
            pepname=pep
    else:
        db[gene][pepname]+=line[0]

for g in db:
    if len(db[g])==1:
        for p in db[g] :
            if g in name:
                #newpep.write('>'+p+'_'+g+'_'+name[g]+'\n'+db[g][p]+'\n')
                newpep.write('>'+p+'_'+name[g]+'\n'+db[g][p]+'\n')
            else:
                newpep.write('>'+p+'\n'+db[g][p]+'\n')
    else:
        length={}
        for p in db[g]:
            length[p]=len(db[g][p])
        sorted_dict = dict(sorted(length.items(), key=lambda x: x[1], reverse=True))
        first_key = list(sorted_dict.keys())[0]
        if g in name:
            #newpep.write('>'+first_key+'_'+g+'_'+name[g]+'\n'+db[g][first_key]+'\n')
            newpep.write('>'+first_key+'_'+name[g]+'\n'+db[g][first_key]+'\n')
        else:
            #newpep.write('>'+first_key+'_'+g+'\n'+db[g][first_key]+'\n')
            newpep.write('>'+first_key+'\n'+db[g][first_key]+'\n')
oldpep.close()
newpep.close()
