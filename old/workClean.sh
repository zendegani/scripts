#!/bin/bash
shopt -s extglob

#now=`date +"%y%m%d%H%M%S"`
now=`date +"%y%m%d%H%M"`
foldName=`echo "cl$now"`
mkdir $foldName
mv !($foldName) $foldName
#mv * $foldName
cd $foldName
cp -t ../ INCAR POSCAR  KPOINTS
cd ../
#if ls $foldName/POTCAR* 1> /dev/null 2>&1; then
#    cp $foldName/POTCAR* .
#    [[ -e POTCAR.gz ]] && gunzip POTCAR.gz
#fi
