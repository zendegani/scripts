#!/bin/bash


POS=${1:-'POSCAR'}
CON=${2:-'CONTCAR'}

echo 'Analysing the symmetries of '$POS $CON ' in  all folders ...'

here=`pwd`
echo "$here"

folder=`ls -1d [0-9].*`
for i in $folder;do
echo $i
cd $i
if [ ! -d "Sym" ]; then
  mkdir Sym
fi
cd Sym
sxstructprint --vasp -i ../$POS  > struct$POS.sx
sxstructsym -i struct$POS.sx > Sym$POS.log
sxstructsym -i struct$POS.sx --nonsymmorphic > SymNonSymmorphic$POS.log

sxstructprint --vasp -i ../$CON  > struct$CON.sx
sxstructsym -i struct$CON.sx > Sym$CON.log
sxstructsym -i struct$CON.sx --nonsymmorphic > SymNonSymmorphic$CON.log

grep 'Symmetry group' Sym$POS.log Sym$CON.log

cd $here

done

