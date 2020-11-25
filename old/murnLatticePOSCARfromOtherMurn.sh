#!/bin/bash
#Garch ver 2020.02.19

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

createSubmissionScript.sh

#--- prepare POSCAR for Murn (normalising the lattice index to 1.0)

here=`pwd`
echogreen $here
read -p "Enter the full path of the murn folder: " murnroot
ls $murnroot
read -n1 -r -p "If the above content is correct, press any key to continue..." key
cd $murnroot
list=`ls -1d [0-9]*/`
cd $here
echoblue "These folders will be entered the calculations: " $list
read -n1 -r -p "Press any key to continue..." key


for a in $list; do
#--- prompt user info
  echo "-------------------------------------------------------"
  echo "  Lat. coef. = $a"
  echo "-------------------------------------------------------"
  mkdir $a
  cd $a
  
  cp ../INCAR ./
  cp ../KPOINTS ./
  ln -s ../POTCAR
  cp $murnroot/$a/CONTCAR POSCAR
#  reoreientStructure.sh
  sbatch ../subscript
  cd $here
done

