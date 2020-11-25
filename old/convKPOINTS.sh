#!/bin/bash
#Garch ver 2016.01.11

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

createSubmissionScript.sh

#--- Define range of K-points
echoblue "Define range of K-points, eg., 1 2 3 .. 8 9 10 "
read -p "Range start [1] : " rangestart
rangestart=${rangestart:-"1"}
read -p "Range end [10] : " rangeend
rangeend=${rangeend:-"10"}
read -p "Range step [1] : " rangestep
rangestep=${rangestep:-"1"}
echogreen $rangestart $rangestep $rangeend

#--- for each value of the K-points list
KP=`awk 'BEGIN{ for (i='$rangestart'; i <= '$rangeend'; i+='$rangestep') printf("%d\n", i); }'`
echogreen $KP
#KP=(7 8 9 10 11 12 13)
#for a in "${KP[@]}"; do
for a in $KP; do
    echo $a
    mkdir $a
    cd $a
    ln -s ../POTCAR
    cp ../POSCAR ./
    cp ../INCAR ./
    #--- prompt user info
    echo "-------------------------------------------------------"
    echo "  KP = $a $a $a"
    echo "-------------------------------------------------------"
    #--- create atomic KPOINTS
    cat > KPOINTS << KPOINTSeof
K-Points
0
G
$a $a $a
0 0 0  
KPOINTSeof
    qsub ../subscript
    cd ..
done
