#!/bin/bash

echo 'convert POSCAR to strcut'
sxstructprint --vasp -i POSCAR > struct.sx

echo 'generating supercell'
sxstructrep -r $1 -i struct.sx -o Sstruct.sx > sxstructrep.log

echo 'convert Supercell to POSCAR'
sx2poscar -i Sstruct.sx -o SPOSCAR > sx2poscar.log

echo 'generating displacements'
sxuniqdispl -d 0.02 -i Sstruct.sx > sxuniqdispl.log

echo 'generating folders and submitting jobs'

echo 'making forces background folder'
mkdir forces_background
cp -rf SPOSCAR forces_background/POSCAR
cd forces_background
cp ../INCAR .
cp ../POTCAR .
cp ../KPOINTS .
#qsub -N J_backF -pe impi_hydra 80 ~/scripts/submit.5.3.5.20cores_woCHG_NEWCONSTRAINS
qsub -N J_backF -pe impi_hydra 80 ~/scripts/submit.5.3.5.20cores_wCHG_NEWCONSTRAINS
cd ..

ndir=`ls -1d i*.* | wc -l`
for (( i=1; i<$ndir+1; i++ )); do 
  echo $i
  echo 1_$i
  sx2poscar -i input-disp-$i.sx -o SPOSCAR$i >> sx2poscar.log
  mkdir 1_$i
  mv SPOSCAR$i 1_$i/POSCAR
  cd 1_$i
  cp ../INCAR .
  cp ../POTCAR .
  cp ../KPOINTS .
  qsub -N J$i -pe impi_hydra 80 ~/scripts/submit.5.3.5.20cores_wCHG_NEWCONSTRAINS
#  qsub -N J$i -pe impi_hydra 80 ~/scripts/submit.5.3.5.20cores_woCHG_NEWCONSTRAINS
  cd ..
done

