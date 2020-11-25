#!/bin/bash
#v 2015.09.21

Eps=${1:-'1.e-3'}
POS=${2:-'POSCAR'}
CON=${3:-'CONTCAR'}
echo $Eps $POS $CON

#POS=${1:-'POSCAR'}
#CON=${2:-'CONTCAR'}

echo 'Analysing the symmetries of '$POS $CON

if [ ! -d "Sym" ]; then
  mkdir Sym
fi

cd Sym
sxstructprint --vasp -i ../$POS  > struct$POS.sx
sxstructsym -e $Eps -i struct$POS.sx > Sym$POS.log
sxstructsym -e $Eps -i struct$POS.sx --nonsymmorphic > SymNonSymmorphic$POS.log

sxstructprint --vasp -i ../$CON  > struct$CON.sx
sxstructsym -e $Eps -i struct$CON.sx > Sym$CON.log
sxstructsym -e $Eps -i struct$CON.sx --nonsymmorphic > SymNonSymmorphic$CON.log

grep 'Symmetry group' Sym$POS.log Sym$CON.log
grep 'Primitive symmetries' Sym$POS.log Sym$CON.log

