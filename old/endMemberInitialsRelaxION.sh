#!/bin/bash
#Garch 2016.01.17

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

createSubmissionScript.sh

#--- prepare POSCAR for Murn (normalising the lattice index to 1.0)
#poscarLatNormalise

root=`pwd`
echoblue "Root:"
echo $root
cd 'Q-Al-Mg'
hereEM=`pwd`
echoblue "End members"

foldersEM=`ls -1d [0-9]*`

for f in $foldersEM; do
    echo "############################" $f
    cd $f/; 
    mkdir 010-relaxVol;
    cd 010-relaxVol;
    cp $root/INCARs/INCAR.0 INCAR;
    cp $root/KPOINTs/KPOINTS.0 KPOINTS;
    ln ../POTCAR;
    cp ../POSCAR .;
    cp $root/subscript .;
    qsub subscript;
    cd $hereEM; 
done
