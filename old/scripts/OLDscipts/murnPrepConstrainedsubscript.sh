#!/bin/bash


lat=(0.98 0.99 1.00 1.01 1.02)
for a in "${lat[@]}"; do
  mkdir $a
  cd $a
  
  cp ../INCAR ./
  cp ../KPOINTS ./
  ln -s ../POTCAR 
  cp ../POSCAR ./

#--- prompt user info
  echo "-------------------------------------------------------"
  echo "  Lat. coef. = $a"
  echo "-------------------------------------------------------"

#--- create POSCAR
#  n0=`wc -l < POSCAR`
#  n=`echo $n0-2 | bc`
  n=`echo $(wc -l < POSCAR)-2 | bc`
  mv POSCAR POSCARtmp
  head -1 POSCARtmp >> POSCAR

  cat >> POSCAR << POSCAReof
$a
POSCAReof
  tail -$n POSCARtmp >> POSCAR
 qsub -l h_rt=12:0:0 -pe impi_hydra 20 ../subscript
 cd ../
done

