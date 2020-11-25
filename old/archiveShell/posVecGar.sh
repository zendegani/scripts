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
  qsub -l h_rt=36:0:0 -pe impi_hydra 20 /cmmc/u/alizen/scripts/G-Q2.sh
  cd ..
done


