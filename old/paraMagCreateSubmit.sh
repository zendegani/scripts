#!/bin/bash
#2017.03.15

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

grep LWAVE INCAR
echored "CAUTION: LWAVE should be F. The WAVECAR in forces_background will be read!"
cat -n  POSCAR | head
echored "Atoms number should be on the line #6"
read -p "You should already replace atoms number in POSACR with series of 1 1 1 1 ...."


createSubmissionScript.sh
read -p "Press enter to continue ..."

echo 'convert POSCAR to strcut'
sxstructprint --vasp -i POSCAR > struct.sx

echo 'generating supercell'
sxstructrep -r 1x1x1 -i struct.sx -o Sstruct.sx > sxstructrep.log

echo 'convert Supercell to POSCAR'
sx2poscar -i Sstruct.sx -o SPOSCAR > sx2poscar.log

echo 'generating displacements'
sxuniqdispl -d 0.02 -i Sstruct.sx > sxuniqdispl.log

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
  ln -s ../POTCAR 
  cp ../KPOINTS .
  ln -s ../forces_background/WAVECAR

#--- create POSCAR replace series of 1 with atom number
  mv POSCAR tmp
  head -5 tmp >> POSCAR
  cat >> POSCAR << POSCAReof
 32 16
POSCAReof
  tail -n +7 tmp >> POSCAR
  qsub  -N PM_$i ../subscript
  cd ..
done

