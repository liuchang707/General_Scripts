#!/usr/env/python
import re
import sys
oldgff=open(sys.argv[1])
#newgff=sys.argv[2]
cdsnum=sys.argv[2]
out1=open(sys.argv[1].strip()+'.want.gff','w')
out2=open(sys.argv[1].strip()+'.other.gff','w')
switch=0
num={}
a=sys.argv[2].strip().split(',')
for i in a :
    print(i)
    num[int(i)]=1

#IN=open(oldgff,'r')
#OUT=open(newgff,'w')
db={}

for line in oldgff:
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
    if db[key]["cdsnum"] not in num:
        out1.write(db[key]["seq"])
    else:
        out2.write(db[key]["seq"])

oldgff.close()
out1.close()
out2.close()



