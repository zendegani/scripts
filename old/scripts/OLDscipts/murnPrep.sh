#!/bin/bash
#2015.09.28

subm=${1:-'-l h_rt=36:0:0 -pe impi_hydra 20 /cmmc/u/alizen/scripts/submit.5.4.1_20woCHG'}

lat=(0.98 0.99 1.0 1.01 1.02)
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
  n0=`cat -n POSCAR | tail -1 | awk '{print $1}'`
  n=`echo $n0-2 | bc`
  mv POSCAR POSCARtmp
  head -1 POSCARtmp >> POSCAR

  cat >> POSCAR << POSCAReof
$a
POSCAReof
  tail -$n POSCARtmp >> POSCAR
  qsub $subm
  cd ../
done

