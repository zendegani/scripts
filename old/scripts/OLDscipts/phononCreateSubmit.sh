#!/bin/bash

echo 'convert POSCAR to strcut'
sxstructprint --vasp -i POSCAR > struct.sx

echo 'generating supercell'
sxstructrep -r $1 -i struct.sx -o Sstruct.sx > sxstructrep.log

echo 'convert Supercell to POSCAR'
sx2poscar -i Sstruct.sx -o SPOSCAR > sx2poscar.log

echo 'generating displacements'
sxuniqdispl -d 0.02 -i Sstruct.sx > sxuniqdispl.log

echo 'making forces background folder'
mkdir forces_background
cp -rf SPOSCAR forces_background/POSCAR
cd forces_background
cp ../INCAR .
cp ../POTCAR .
cp ../KPOINTS .
qsub -N JbackF -l h_rt=36:0:0 -pe impi_hydra 20 /cmmc/u/alizen/scripts/G-Q2.sh
cd ..






echo 'generating folders and submitting jobs'
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
  qsub  -N J$i -l h_rt=36:0:0 -pe impi_hydra 20 /cmmc/u/alizen/scripts/G-Q2.sh
  cd ..
done

