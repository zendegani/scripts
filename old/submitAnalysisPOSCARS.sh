#!/bin/bash
#Garch 2017.02.21

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

createSubmissionScript.sh

here=`pwd`
list=`ls -1d POSCAR_*`
for i in $list ; do
    new=`echo $i| sed 's/POSCAR_//'`;
    echo $new;
    mkdir $new;
    cd $new;
    cp ../$i POSCAR;
    cp ../{INCAR,KPOINTS} .;
    ln -s ../POTCAR;
    qsub ../subscript;
    cd -;
done
