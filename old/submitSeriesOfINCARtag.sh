#!/bin/bash
#Garch 2020.02.27

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

createSubmissionScript.sh

#--- prepare POSCAR for Murn (normalising the lattice index to 1.0)
#echoblue "This is the POSCAR header"
#echored "----------------------"
#head POSCAR
#echored "----------------------"
#read -p "Would you like to normalise universal scaling factor ('lattice constant') to 1.0 ([No]/Yes)? " normaliseanswer
#normaliseanswer=${normaliseanswer:-"No"}
#shopt -s nocasematch
#[[ "$normaliseanswer" != "No" ]] && poscarLatNormalise || echogreen "Normalisation skipped"
#shopt -u nocasematch

echoblue -n "Enter INCAR tag name and press [ENTER]: "
read tag
checkINCARtag $tag
echo -n "Enter values for the $tag seperated by space and press [ENTER]: "
read values

for value in ${values[@]}; do
  echo "#------ Folder: " $value
  mkdir $value
  cd $value
  cp ../{INCAR,KPOINTS,POSCAR} ./
  ln ../POTCAR
  substINCARtagVALUE $tag $value
  sbatch ../subscript
  cd ../
done

