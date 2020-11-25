#!/bin/sh


## Name your folder
poscar=`ls -1d POSCAR_[0-1].[0-9]*`

for i in $poscar;do
  echo D$i
  mkdir D$i
  cd D$i
  mv ../$i ./POSCAR
  cp ../INCAR .
  cp ../KPOINTS .
  cp ../POTCAR .  
  qsub -pe 'mpi*' 24 ~/scripts/Q.sh
  cd ..
done


