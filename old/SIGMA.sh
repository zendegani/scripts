#!/bin/bash
shopt -s expand_aliases
source ~/.bashrc

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . ~/scripts/azfunctions.include;

#values=`seq .01 .01 .18`
values=`seq .10 .01 .18`
substINCARtagVALUE "ISMEAR" "-1"
tagg=SIGMA
checkINCARtag $tagg 

for value in ${values[@]}; do
  echo "#------ Folder: " $value # tag: $tag $tagg
  mkdir $value
  cd $value
  cp ../{INCAR,KPOINTS,POSCAR} ./
  ln -s ../POTCAR
  ln -s ../../forces_background/WAVECAR
  substINCARtagVALUE $tagg $value
  sbatch ../subscript
  cd ../
done
#
