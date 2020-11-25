#!/bin/bash
#Garch ver 2016.07.22

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

createSubmissionScript.sh

#--- Define universal scaling factor ('lattice constant') range
echoblue "Define universal scaling factor ('lattice constant') range, eg., 0.98 0.99 1.00 1.01 1.02 "
read -p "Range start [0.97] : " rangestart
rangestart=${rangestart:-"0.97"}
read -p "Range end [1.03] : " rangeend
rangeend=${rangeend:-"1.03"}
read -p "Range step [0.01] : " rangestep
rangestep=${rangestep:-"0.01"}
echogreen $rangestart $rangestep $rangeend

lat=`awk 'BEGIN{ for (i='$rangestart'; i <= '$rangeend'; i+='$rangestep') printf("%.4f\n", i); }'`
root=`pwd`
rootlist=`ls -1d [0-9]*`
for shift in $rootlist; do
 cp INCAR KPOINTS $shift
 cd $shift

for a in $lat; do
  echored $a
  mkdir $a
  cd $a
  
  cp ../INCAR ./
  cp ../KPOINTS ./
  ln -s $root/POTCAR 
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
  qsub $root/subscript
  cd ../
done
cd $root
done
