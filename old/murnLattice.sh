#!/bin/bash
#Garch ver 2016.07.22

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

createSubmissionScript.sh

#--- prepare POSCAR for Murn (normalising the lattice index to 1.0)
echoblue "This is the POSCAR header"
echored "----------------------"
head POSCAR
echored "----------------------"
read -p "Would you like to normalise universal scaling factor ('lattice constant') to 1.0 ([No]/Yes)? " normaliseanswer
normaliseanswer=${normaliseanswer:-"No"}
shopt -s nocasematch
[[ "$normaliseanswer" != "No" ]] && poscarLatNormalise || echogreen "Normalisation skipped"
shopt -u nocasematch

#--- Define universal scaling factor ('lattice constant') range
echoblue "Define universal scaling factor ('lattice constant') range, eg., 0.98 0.99 1.00 1.01 1.02 "
read -p "Range start [0.98] : " rangestart
rangestart=${rangestart:-"0.98"}
read -p "Range end [1.025] : " rangeend
rangeend=${rangeend:-"1.025"}
read -p "Range step [0.005] : " rangestep
rangestep=${rangestep:-"0.005"}
echogreen $rangestart $rangestep $rangeend

lat=`awk 'BEGIN{ for (i='$rangestart'; i <= '$rangeend'; i+='$rangestep') printf("%.4f\n", i); }'`

for a in $lat; do
  echored $a
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
  head -1 POSCARtmp > POSCAR

  cat >> POSCAR << POSCAReof
$a
POSCAReof
  tail -$n POSCARtmp >> POSCAR
  sbatch ../subscript
  cd ../
done

