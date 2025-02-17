#!/usr/env/python
import sys
import re
import os

if (len(sys.argv) <2): #判断命令行参数个数
    print('usage:\n python '+sys.argv[0]+' <fasta_seq> <len_cut[100]> > out_file \n')
F=open(sys.argv[1],'r')
cutoff_len=(sys.argv[2] or 100)#与或非 and or not
array_len=[]
total_len=0
total_len_100=0
total_len_1000=0
total_len_2000=0
total_len_5000=0
total_len_10k=0
length=0
average_len=0

for line in F:
    line=line.strip()
    if re.search(r'^>',line):
        if length>=int(cutoff_len):
            total_len+=length
            if length>=100 :
                total_len_100+=1 #没有++，只有+=
            if length>=1000 :
                total_len_1000+=1
            if length>=2000 :
                total_len_2000+=1
            if length>=5000 :
                total_len_5000+=1
            if length>=10000:
                total_len_10k+=1
            array_len.append(length)
        length=0
    else :
       length +=len(line)
F.close()
total_len+=length
if length>=100: total_len_100+=1
if length>=1000: total_len_1000+=1
if length>=2000: total_len_2000+=1
if length>=5000: total_len_5000+=1
if length>=10000: total_len_10k+=1
array_len.append(length)

def nx(Len):#python 只能先定义后引用
    nlen=0
    for i in range(len(array_len)):
        nlen += array_len[i]
        if nlen*100>=total_len*Len:
            return(array_len[i],i+1)
            break
array_len.sort(reverse=True)
for n in range(90,0,-10): #以10为步长，递减
    nlen,index= nx(n)
    print ('N'+str(n)+'\t'+str(nlen)+'\t'+str(index))
average_len=int(total_len/len(array_len))
print ('Max length = '+str(array_len[0]))
print ('Total length = '+str(total_len)+'\tTotal number = '+str(len(array_len))+'\tAverage length = '+str(average_len))
print ('Number>=100bp = '+str(total_len_100)+'\tNumber>=1000bp = '+str(total_len_1000)+'\tNumber>=2000bp = '+str(total_len_2000)+'\tNumber>=5000bp = '+str(total_len_5000)+'\tNumber>=10kbp = '+str(total_len_10k))

