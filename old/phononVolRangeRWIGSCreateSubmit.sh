#!/bin/bash
#2016-07-29

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

here=`pwd`
echogreen $here
createSubmissionScript.sh
read -p "Enter the full path of the murn folder: " murnroot
ls $murnroot
read -n1 -r -p "If the above content is correct, press any key to continue..." key
list=`ls -1d [0-9]*/`
echoblue "These folders will be entered the calculations: " $list
read -p "Enter supercell dimension, e.g. 2x2x3: " supercel_dim
echogreen "Supercell dimension" $supercel_dim
read -n1 -r -p "Press any key to continue..." key
for i in $list ; do 
	echored $i 
	cd $i
	cp ../{INCAR,KPOINTS} . 
	cp $murnroot/$i/POSCAR .
	rwig=`grep RWIG $murnroot/$i/INCAR`
	sed -i "s/RWIG.*/$rwig/" INCAR
	ln -s /u/alizen/POT/PAW-GGA-PBE_vasp5.2/FeNb_8_11/POTCAR
    cp ../subscript .
	phononCreateSubmitArgument.sh $supercel_dim
	read -n1 -r -p "Press any key to continue..." key
	cd $here
done

