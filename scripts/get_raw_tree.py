import re
import sys
inf=open(sys.argv[1])
out=open(sys.argv[2],'w')
for line in inf:
	#moduel =re.compile('{\.\S+:0\.\d+}')
	moduel =re.compile('\d+\.\d+')
	info = re.sub(moduel,'',line)
	info=info.replace(':','')
	moduel =re.compile('\.\w+')
	inf1=re.sub(moduel,'',info)
	inf1=inf1.replace('.','')
	out.write(inf1)

inf.close
out.close
	
