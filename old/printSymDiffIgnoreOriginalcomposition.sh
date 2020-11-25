#!/bin/bash
#v 2016.0813

Eps=${1:-'1.e-3'}
POS=${2:-'POSCAR'}
CON=${3:-'CONTCAR'}
echo $Eps $POS $CON

#POS=${1:-'POSCAR'}
#CON=${2:-'CONTCAR'}

echo 'Analysing the symmetries of '$POS $CON ' replacing the initial composition'

if [ ! -d "Sym" ]; then
  mkdir Sym
fi

tmpPOS="tmpPOS"
tmpCON="tmpCON"

cp $POS $tmpPOS
cp $CON $tmpCON

POS=$tmpPOS
CON=$tmpCON

head $POS
head $CON

read -p "Enter the new atmoic symbols? " symbols
read -p "Enter the new number of the atoms?" natoms

sed -i "6s/.*/$symbols/" $POS
sed -i "6s/.*/$symbols/" $CON

sed -i "7s/.*/$natoms/" $POS
sed -i "7s/.*/$natoms/" $CON

cd Sym
sxstructprint --vasp -i ../$POS  > struct$POS.sx
sxstructsym -e $Eps -i struct$POS.sx > Sym$POS.log
sxstructsym -e $Eps -i struct$POS.sx --nonsymmorphic > SymNonSymmorphic$POS.log

sxstructprint --vasp -i ../$CON  > struct$CON.sx
sxstructsym -e $Eps -i struct$CON.sx > Sym$CON.log
sxstructsym -e $Eps -i struct$CON.sx --nonsymmorphic > SymNonSymmorphic$CON.log

grep 'Symmetry group' Sym$POS.log Sym$CON.log
grep 'Primitive symmetries' Sym$POS.log Sym$CON.log

