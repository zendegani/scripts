#!/bin/bash
#ver 2017-01-16

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

tmpFileName=spaceGroup.log

#--- echoblue "This is the POSCAR header"
echoblue "------ Checking the symmetries of files in folders..."
read -p "Enter the file name POSCAR/[CONTCAR]/...: " fileName
fileName=${fileName:-"CONTCAR"}
read -p "Enter the threshold [.001]: " threshold
threshold=${threshold:-".001"}
echoblue "------ File: $fileName, Threshold: $threshold"
here=`pwd`
list=`ls -1d [0-9]*`
echogreen "Folders  | Pointgroup | Space group"
for i in $list ;do
    cd $i;
    getSpaceGroup.sh -i $fileName -t $threshold > $tmpFileName
    var1=`grep "Space group" $tmpFileName | cut -d":" -f2`
    var2=`grep "Point group" $tmpFileName | cut -d":" -f2`
    echo $i "|" $var2 "|" $var1
    rm $tmpFileName
    cd $here;
done


