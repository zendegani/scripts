#!/bin/bash
#Garch 2016-01-13

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

createSubmissionScript.sh

read -p "Press enter to continue"

perfect_name="forces_background"
mkdir $perfect_name
echo $perfect_name
cp ./{INCAR,KPOINTS} $perfect_name
cp SPOSCAR $perfect_name/POSCAR
cd $perfect_name
ln -s ../POTCAR
qsub -N $perfect_name ../subscript
cd -
for j in `/bin/ls POSCAR-*`;do
    dispname=`echo $j|sed s/POSCAR/disp/`
    echo $dispname
    mkdir $dispname
    cp $j $dispname/POSCAR
    cp ./{INCAR,KPOINTS} $dispname/
    cd $dispname
    ln -s ../POTCAR
    qsub -N $dispname ../subscript
    cd -
done
