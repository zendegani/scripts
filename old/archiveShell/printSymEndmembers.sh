#!/bin/bash


POS=${1:-'SPOSCAR'}
Eps=${2:-'1.e-3'}
echo $POS $Eps

echo 'Analysing the symmetries of '$POS ' with eps ' $Eps ' in  all folders ...'

here=`pwd`
echo "$here"
echo 'Sym Gr     nonSymmorphic    Eps'$2
echo 'Prim sym   nonSymmorphic    Eps'$2

folder=`ls -1d [1-9]*`
for i in $folder;do
#echo $i
cd $i
if [ ! -d "Sym" ]; then
  mkdir Sym
fi
cd Sym
sxstructprint --vasp -i ../finite/$POS  > struct$POS.sx
sxstructsym -i struct$POS.sx > Sym$POS.log
sxstructsym -i struct$POS.sx --nonsymmorphic > SymNonSymmorphic$POS.log
sxstructsym -i struct$POS.sx --nonsymmorphic -e $Eps > SymEps$POS.log

echo '#End member: ' $i
grep 'Symmetry group' Sym$POS.log SymNonSymmorphic$POS.log SymEps$POS.log | tr '\n' ' ' | awk '{print "   " $4 "           " $9 "            " $14}' | sed 's/[()]//g'
grep 'Primitive symmetries' Sym$POS.log SymNonSymmorphic$POS.log SymEps$POS.log | tr '\n' ' ' | awk '{print "   " $4 "           " $10 "            " $16}'

cd $here

done

