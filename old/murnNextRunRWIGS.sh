#!/bin/bash
#2016.04.28

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
    mv * $old/
    cp $old/CONTCAR ./POSCAR
    cp $old/KPOINTS .
    cp ../INCAR ./
    rwig=`grep RWIG $old/INCAR`
    echo $rwig
    sed -i "s/.*RWIGS.*/$rwig/" INCAR
    ln -s ../POTCAR
    qsub ../subscript
    cd ../
done

