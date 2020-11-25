#!/bin/bash
#Garch ver 2016.01.14

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

#createSubmissionScript.sh


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

#--- read vector from POSCAR
echoblue "This is the POSCAR header"
echored "----------------------"
head -5 POSCAR | tail -3
echored "----------------------"
a=`awk 'NR==3 {print $1}' POSCAR`
c=`awk 'NR==5 {print $3}' POSCAR`
echoblue "a=" $a " c= " $c
ratio=`printf "%.4f" $(echo "scale=2;$a/$c" | bc)`
echored "Ratio of a/c = " $ratio

#KP=(7 8 9 10 11 12 13)
#for a in "${KP[@]}"; do
for k in $KP; do
    echo $k
    mkdir $k
    cd $k
    ln ../POTCAR
    cp ../POSCAR ./
    cp ../INCAR ./

    if (( $(bc <<< "$ratio>1.0") > 0 )); then
        aa=$k
        cc=`printf "%.0f" $(echo "scale=2;$k*$ratio" | bc)`
    else
        cc=$k
        aa=`printf "%.0f" $(echo "scale=2;$k/$ratio" | bc)`
    fi
    #--- prompt user info
    echo "-------------------------------------------------------"
    echo "  KP = $aa $aa $cc  "
    echo "-------------------------------------------------------"
    #--- create atomic KPOINTS
    cat > KPOINTS << KPOINTSeof
K-Points
0
G
$aa $aa $cc
0 0 0
KPOINTSeof
#    qsub ../subscript
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


