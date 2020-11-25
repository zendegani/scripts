#!/bin/bash
#2016-04-22

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

sxstruct=struct.sx

read -p "Enter vasp-type input file name [POSCAR]: " filename
filename="${filename:-"POSCAR"}"
cp $filename ini$filename

echo 'convert $filename to strcut'
sxstructprint --vasp -i $filename > $sxstruct

echo 'reorienting and symmetrizing the strcuture'
sxstructsym  --symmetrize-cell -i $sxstruct -o reoriented_$sxstruct
#sxstructsym --reorient  --symmetrize-cell -i $sxstruct -o reoriented_$sxstruct 
#sxstructsym --reorient   -i $sxstruct -o reoriented_$sxstruct


echo 'convert reoriented structure back to vasp-compatible'
sx2poscar -i reoriented_$sxstruct -o reoriented_$filename > sx2poscar.log

cp reoriented_$filename $filename
