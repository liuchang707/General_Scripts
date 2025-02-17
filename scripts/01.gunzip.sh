#!/bin/bash
if [$# -ne 1]
then
  echo "Usage:$0 dir"
  exit 1
fi

cd $1
echo `pwd`
d=$1

function dir()
{
         for dir in `ls $1 | grep 'small'`
         do
           if test -d $dir
           then
               echo $dir
               #echo `pwd`
           for subdir in `ls $dir `
           do 
             
             #echo $subdir
             if test -d  $dir"/"$subdir
             then 
                 #echo this is a diretoy
                 #echo $subdir
                # cd $subdir
                 for file in `ls "./"$dir"/"$subdir | grep 'cor\.pair.*fq.gz'`
                 do
                   #cd $subdir
                   echo $file
                   length=${#file}
                   #echo $length
                   gunzip_file=${file:0:$length-3}
                   echo $gunzip_file
                   #echo "./"$dir"/"$subdir"/"$file ">" "./"$dir"/"$subdir"/"$gunzip_file
                   gunzip -c "./"$dir"/"$subdir"/"$file  > "./new_small/"$subdir"/"$gunzip_file
                 done
             fi
           done
           fi
         done
         
                 }
dir $d
