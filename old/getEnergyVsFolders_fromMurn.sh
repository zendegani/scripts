#!/bin/bash

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

hier=`pwd`
echo "$hier"
## Name your folder
folder=`ls -1d [0-9]*`
#echo $folder
## Creat output file 
file1=Folder_eV.dat

murn=murn.dat

echo "#Folder   E0     V0 "  > $file1

for i in $folder;do
 cd $i
 echo "$i"

 Energy=`awk '/minimum energy E0/ {print $NF}' $murn`
 Vol=`awk '/optimal volume V0/ {print $NF}' $murn` 

 cd $hier

 echo "$i    $Energy    $Vol" >> $file1
done

