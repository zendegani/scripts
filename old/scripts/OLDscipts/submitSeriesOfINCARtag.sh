#!/bin/bash
#2015.11.05

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

createSubmissionScript.sh

#--- prepare POSCAR for Murn (normalising the lattice index to 1.0)
poscarLatNormalise

echo -n "Enter INCAR tag name and press [ENTER]: "
read tag
checkINCARtag $tag
echo -n "Enter values for the $tag seperated by space and press [ENTER]: "
read values

for value in ${values[@]}; do
  echo "#------ Folder: " $value
  mkdir $value
  cd $value
  cp ../{INCAR,KPOINTS,POSCAR} ./
  ln -s ../POTCAR 
  substINCARtagVALUE $tag $value
  qsub ../subscript
  cd ../
done

