#!/bin/bash
#Garch ver 2016.01.14

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

createSubmissionScript.sh


#--- Define range of K-points
echoblue "Define range of K-points, eg., 10 20 30 .. 80 90 100 "
read -p "Range start [10] : " rangestart
rangestart=${rangestart:-"10"}
read -p "Range end [100] : " rangeend
rangeend=${rangeend:-"100"}
read -p "Range step [10] : " rangestep
rangestep=${rangestep:-"10"}
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
    ln ../POTCAR
    cp ../POSCAR ./
    cp ../INCAR ./
    #--- prompt user info
    echo "-------------------------------------------------------"
    echo "  KP = $a ..."
    echo "-------------------------------------------------------"
    #--- create atomic KPOINTS
    cat > KPOINTS << KPOINTSeof
K-Points
0
A
$a 
KPOINTSeof
    qsub ../subscript
    cd ..
done


#--- List of K-points
#KP=(7 8 9 10 11 12 13)

#--- for each value of the K-points list
#for a in "${KP[@]}"; do
#  KPL=`printf "%.0f" $(echo "scale=2;$a*1.63" | bc)`
#--- create atomic KPOINTS
#  cat > KPOINTS << KPOINTSeof
#K-Points
# 0
#G
# $KPL $KPL $a
# 0 0 0
#KPOINTSeof


