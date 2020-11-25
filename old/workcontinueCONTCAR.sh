#!/bin/bash
#v2015.12.31

now=`date +"%y%m%d%H%M%S"`
#now=`date +"%y%m%d%k%M"`
foldName=`echo "cont$now"`
mkdir $foldName
mv * $foldName
cd $foldName
cp CONTCAR ../POSCAR
cp -t ../ INCAR KPOINTS 
#cp -t ../ INCAR KPOINTS POTCAR*
cd ..
#gunzip POTCAR.gz
