#!/bin/bash
#Garch ver 2018.06.29

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

createSubmissionScript.sh

#--- prepare POSCAR for Murn (normalising the lattice index to 1.0)
echored "CAUTION: You should set ISIF = 2 in the INCAR otherwise ..."
echoblue `grep -i ISIF INCAR`
echored "CAUTION: Use negative vol to keep vol fix while changing z value of c vector"
echoblue "This is the POSCAR header"
echored "----------------------"
head POSCAR
echored "----------------------"
read -p "Would you like to normalise universal scaling factor ('lattice constant') to 1.0 ([No]/Yes)? " normaliseanswer
normaliseanswer=${normaliseanswer:-"No"}
shopt -s nocasematch
[[ "$normaliseanswer" != "No" ]] && poscarLatNormalise || echogreen "Normalisation skipped"
shopt -u nocasematch

read -p "Enter c_x and c_y of c_vector if they are not 0.0: " cvectoranswer
cvectoranswer=${cvectoranswer:-"     0.0000000000000000    0.0000000000000000   "}

#--- Define universal scaling factor ('lattice constant') range
echored "CAUTION: The c vector will be written as 0.00 0.00 x.xx"
echoblue "Define a range for c"
read -p "Range start [1] : " rangestart
rangestart=${rangestart:-"1"}
read -p "Range end [10] : " rangeend
rangeend=${rangeend:-"10"}
read -p "Range step [0.1] : " rangestep
rangestep=${rangestep:-"0.1"}
echogreen $rangestart $rangestep $rangeend

lat=`awk 'BEGIN{ for (i='$rangestart'; i <= '$rangeend'; i+='$rangestep') printf("%.4f\n", i); }'`

for c in $lat; do
  echored $c
  mkdir $c
  cd $c
  
  cp ../INCAR ./
  cp ../KPOINTS ./
  ln -s ../POTCAR 
  cp ../POSCAR ./

#--- prompt user info
  echo "-------------------------------------------------------"
  echo "  c  = $c"
  echo "-------------------------------------------------------"

#--- create POSCAR
  mv POSCAR POSCARtmp
  head -4 POSCARtmp > POSCAR

  cat >> POSCAR << POSCAReof
$cvectoranswer $c
POSCAReof
  tail -n +6 POSCARtmp >> POSCAR
  qsub ../subscript
  cd ../
done

