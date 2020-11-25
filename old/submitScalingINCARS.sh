#!/bin/bash
#Garch 2017.05.02

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

createSubmissionScript.sh

here=`pwd`
INCARlist=`ls -1d INCAR[0-9]*`
list=`ls -1d [0-9]*`
for i in $list ; do
    echo $i;
    cd $i;
    for j in $INCARlist; do
        new=`echo $j| sed 's/INCAR//'`;
        echo $new;
        mkdir $new;
        cd $here/$i/$new;
        cp $here/$i/{POSCAR,KPOINTS} .;
        cat $here/$i/INCAR $here/$j > INCAR
        ln -s $here/POTCAR;
        qsub $here/subscript;
        cd $here/$i;
    done
    cd $here
done
