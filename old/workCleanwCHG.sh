#!/bin/bash

#now=`date +"%y%m%d%k%M"`
now=`date +"%y%m%d%H%M%S"`
foldName=`echo "cl$now"`
mkdir $foldName
mv * $foldName
cd $foldName
mv -t ../ INCAR POSCAR POTCAR* KPOINTS CHGCA* WAVECA*
cd ../
gunzip POTCAR.gz CHGCAR.gz WAVECAR.gz




