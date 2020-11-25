#!/bin/bash
#Garch ver 2016.07.22

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

createSubmissionScript.sh

#--- prepare POSCAR for Murn (normalising the lattice index to 1.0)
echoblue "This is the POSCAR header"
echored "----------------------"
cat -n POSCAR
echored "----------------------"
read -p "Would you like to normalise universal scaling factor ('lattice constant') to 1.0 ([No]/Yes)? " normaliseanswer
normaliseanswer=${normaliseanswer:-"No"}
shopt -s nocasematch
[[ "$normaliseanswer" != "No" ]] && poscarLatNormalise || echogreen "Normalisation skipped"
shopt -u nocasematch

read -p  "Enter the number of last line that should keep fix: " linenumber

#--- Define universal scaling factor ('lattice constant') range
read -p "Range start of Z [0.975] : " rangestart
rangestart=${rangestart:-"0.975"}
read -p "Range end of Z  [1.035] : " rangeend
rangeend=${rangeend:-"1.035"}
read -p "Range step [0.005] : " rangestep
rangestep=${rangestep:-"0.005"}
echogreen $rangestart $rangestep $rangeend

lat=`awk 'BEGIN{ for (i='$rangestart'; i <= '$rangeend'; i+='$rangestep') printf("%.5f\n", i); }'`

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
  echo "  Z coordinate = $a"
  echo "-------------------------------------------------------"

#--- create POSCAR
  mv POSCAR POSCARtmp
  head -n $linenumber POSCARtmp > POSCAR
  cat >> POSCAR << POSCAReof
  0.0000000000000000  0.0000000000000000   $a
POSCAReof
  qsub ../subscript
  cd ../
done

