#!/usr/env/python
import re
import sys
gff=open(sys.argv[1])
#newgff=sys.argv[2]
out=open(sys.argv[1].strip()+'.cdsnum','w')
switch=0
#IN=open(gff,'r')
#OUT=open(newgff,'w')
db={}

for line in gff:
    l=line
    line=line.strip().split()
    gene=line[8].split(';')[0].split('=')[1]
    if line[2] == 'mRNA':
        if gene not in db:
            db.update({gene:{}})
            if "cdsnum" not in db[gene]:
                db[gene].update({"cdsnum":0})
            if "seq" not in db[gene]:
                db[gene].update({"seq":l})
    elif line[2] =='CDS':
        db[gene]["cdsnum"]+=1
        db[gene]["seq"]+=l

for key in db:
    out.write(key+'\t'+str(db[key]["cdsnum"])+'\n')

gff.close()
out.close()



