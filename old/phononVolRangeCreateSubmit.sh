#!/bin/bash
set -e
shopt -s expand_aliases
source ~/.bashrc


# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

here=`pwd`
echogreen $here
createSubmissionScript.sh
list=`ls -1d [0-9]*`
echoblue "These folders will be entered the calculations: " $list
read -p "Enter supercell dimension, e.g. 2x2x3: " supercel_dim
echogreen "Supercell dimension" $supercel_dim
read -n1 -r -p "Press any key to continue..." key
for i in $list ; do 
	echored $i 
	cd $i
	magmom=`magSuperCell.py`
	jrepMAGCON $magmom	
	cp relax/CONTCAR POSCAR
	ln -s ../POTCAR
        cp ../subscript .
	phononCreateSubmitArgument.sh $supercel_dim
	read -n1 -r -p "Press any key to continue..." key
	cd $here
done

