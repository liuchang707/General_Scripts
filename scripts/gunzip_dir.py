#!/usr/bin/python
import os
import re
import sys
#gunzip file to its original dir
if len(sys.argv)<3:
	print ("python "+sys.argv[0]+' input dir qsub_file_dir')
	exit()
indir=sys.argv[1]
outdir=sys.argv[2]
os.mkdir('/lustre/home/wangwenlab/liuchang/scripts/'+outdir)
count=1
for root,dir,files in os.walk(indir):
	if len(dir)==0:
		file_o=open('/lustre/home/wangwenlab/liuchang/scripts/'+outdir+'/qsub.sh','w')
		print('/lustre/home/wangwenlab/liuchang/scripts/'+outdir+'/qsub.sh')
		for file in files:
			out=open('/lustre/home/wangwenlab/liuchang/scripts/'+outdir+'/'+str(count)+'.sh','w')
			if re.search(r'(^.*).gz',file):
				name=re.search(r'(^.*).gz',file)
				filename=name.group(1)
				out.write('gunzip -c '+root+'/'+file+' >'+root+'/'+filename+'\n')
				file_o.write('qsub -q old '+str(count)+'.sh && echo done!\n')
				out.close()
			count+=1
file_o.close()
	

