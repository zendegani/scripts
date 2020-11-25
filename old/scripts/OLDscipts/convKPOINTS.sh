#!/bin/bash

#--- List of K-points
KP=(7 8 9 10 11 12 13)

#--- for each value of the K-points list
for a in "${KP[@]}"; do
  KPL=`printf "%.0f" $(echo "scale=2;$a*1.63" | bc)`
  mkdir $a
  cd $a
  cp ../POTCAR ./
  cp ../POSCAR ./
  cp ../INCAR ./
#--- prompt user info
  echo "-------------------------------------------------------"
  echo "  KP = $KPL $KPL $a"
  echo "-------------------------------------------------------"

#--- create atomic KPOINTS
  cat > KPOINTS << KPOINTSeof
K-Points
 0
G
 $KPL $KPL $a
 0 0 0  
KPOINTSeof

  qsub -l h_rt=36:0:0 -pe impi_hydra 20 /cmmc/u/alizen/scripts/G-Q2.sh
  cd ..
done


