#!/bin/bash
#2016.08.05

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

createSubmissionScript.sh
echoblue "***** Template of the script for job submission is created"
#--- prepare POSCAR for Murn (normalising the lattice index to 1.0)
#poscarLatNormalise
#echoblue "***** POSCAR is normalised"
echo ""

FeRWIGS=1.3
NbRWIGS=1.5
RWIGSco=1.00

echoblue "Define the RWIGS scaling for each volumes RWIGS*n_step*scaling "
read -p "Enter the RWIGS scaling [0.0077]: " RWIGScoStep
RWIGScoStep=${RWIGScoStep:-"0.0077"}

here=`pwd`
echogreen $here
read -p "Enter the full path of the murn folder: " murnroot
ls $murnroot
read -n1 -r -p "If the above content is correct, press any key to continue..." key
cd $murnroot
list=`ls -1d [0-9]*/`
cd $here
echoblue "These folders will be entered the calculations: " $list
read -n1 -r -p "Press any key to continue..." key

for a in $list; do
    #--- prompt user info
    echo "-------------------------------------------------------"
    echogreen "  Lat. coef. = $a"
    echo "-------------------------------------------------------"

    mkdir $a
    cd $a

    cp ../INCAR ./
    cp ../KPOINTS ./
    ln -s ../POTCAR 
    cp $murnroot/$a/CONTCAR POSCAR

    RWIGSco=`echo "$RWIGSco+$RWIGScoStep" | bc`
    Fe=`echo "$FeRWIGS*$RWIGSco" | bc`
    Nb=`echo "$NbRWIGS*$RWIGSco" | bc`
    percent=`echo "($RWIGSco-1.0)*100" | bc`
    echoblue "RWIGS increase in percentage: $percent"
    value=`echo "$Fe    $Nb   "\!"radius of wigner-seitz $percent% increased "`
    substINCARtagVALUE RWIGS $value

    qsub ../subscript
    cd $here
done

