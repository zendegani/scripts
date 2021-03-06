#!/bin/bash

#--- List of LAMBDA
L=(1 5 10 20 50 100)

#--- for each value of the list
for a in "${L[@]}"; do
  mkdir $a
  cd $a
  cp ../POTCAR ./
  cp ../POSCAR ./
  cp ../KPOINTS ./
  cp ../INCAR ./
#--- prompt user info
  echo "-------------------------------------------------------"
  echo "  LAMBDA = $a"
  echo "-------------------------------------------------------"

#--- complete INCAR
  cat >> INCAR << INCAReof

 LAMBDA = $a

INCAReof

 qsub -pe impi_hydra 20 ~/scripts/submit.5.3.5.20cores_woCHG_NEWCONSTRAINS
 cd ..
done


