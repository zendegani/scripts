#!/bin/bash
#2015.11.05

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

createSubmissionScript.sh

#--- prepare POSCAR for Murn (normalising the lattice index to 1.0)
poscarLatNormalise


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
  n=`echo $(wc -l < POSCAR)-2 | bc`
  mv POSCAR POSCARtmp
  head -1 POSCARtmp >> POSCAR

  cat >> POSCAR << POSCAReof
$a
POSCAReof
  tail -$n POSCARtmp >> POSCAR
  qsub ../subscript
  cd ../
done

