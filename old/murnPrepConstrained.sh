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
  n0=`cat -n POSCAR | tail -1 | awk '{print $1}'`
  n=`echo $n0-2 | bc`
  mv POSCAR POSCARtmp
  head -1 POSCARtmp >> POSCAR

  cat >> POSCAR << POSCAReof
$a
POSCAReof
  tail -$n POSCARtmp >> POSCAR
#  qsub -l h_rt=36:0:0 -pe impi_hydra 20 /cmmc/u/alizen/scripts/G-Q2.sh
  qsub -pe impi_hydra 20 ~/scripts/submit.5.3.5.20cores_woCHG_NEWCONSTRAINS 
# qsub -pe impi_hydra 20 ~/scripts/submit.5.4.1_20_ncl_woCHG
 cd ../
done

