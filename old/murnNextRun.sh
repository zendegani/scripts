#!/bin/bash
#2016.04.22

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

#createSubmissionScript.sh
#echoblue "***** Template of the script for job submission is created"
#--- prepare POSCAR for Murn (normalising the lattice index to 1.0)
#poscarLatNormalise
#echoblue "***** POSCAR is normalised"
echo ""
read -p "Enter the last calc step number: " old

list=`ls -1d [0-9]*`
for a in $list; do
    #--- prompt user info
    echo "-------------------------------------------------------"
    echogreen "   $a"
    echo "-------------------------------------------------------"
    cd $a
    mkdir $old
    mv * $old/ 2>/dev/null
    cp $old/CONTCAR ./POSCAR
    cp $old/KPOINTS .
    cp ../INCAR ./
    ln -s ../POTCAR
    sbatch ../subscript
    cd ../
done

