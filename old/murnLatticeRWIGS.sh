#!/bin/bash
#2016.06.24

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

#--- Define universal scaling factor ('lattice constant') range
echoblue "Define universal scaling factor ('lattice constant') range, eg., 0.98 0.99 1.00 1.01 1.02 "
read -p "Range start [0.970]: " rangestart
rangestart=${rangestart:-"0.970"}
read -p "Range end [1.040]: " rangeend
rangeend=${rangeend:-"1.040"}
read -p "Range step [0.005]: " rangestep
rangestep=${rangestep:-"0.005"}
echogreen $rangestart $rangestep $rangeend

lat=`awk 'BEGIN{ for (i='$rangestart'; i <= '$rangeend'; i+='$rangestep') printf("%.3f\n", i); }'`

for a in $lat; do
    #--- prompt user info
    echo "-------------------------------------------------------"
    echogreen "  Lat. coef. = $a"
    echo "-------------------------------------------------------"

    mkdir $a
    cd $a

    cp ../INCAR ./
    cp ../KPOINTS ./
    ln -s ../POTCAR 
    cp ../POSCAR ./
#    ln -s ../WAVECAR

    RWIGSco=`echo "$RWIGSco+$RWIGScoStep" | bc`
    Fe=`echo "$FeRWIGS*$RWIGSco" | bc`
    Nb=`echo "$NbRWIGS*$RWIGSco" | bc`
    percent=`echo "($RWIGSco-1.0)*100" | bc`
    echoblue "RWIGS increase in percentage: $percent"
    value=`echo "$Fe    $Nb   "\!"radius of wigner-seitz $percent% increased "`
    substINCARtagVALUE RWIGS $value

    #--- create POSCAR
    n=`echo $(wc -l < POSCAR)-2 | bc`
    mv POSCAR POSCARtmp
    head -1 POSCARtmp >> POSCAR

    cat >> POSCAR << POSCAReof
$a
POSCAReof
    tail -$n POSCARtmp >> POSCAR
    qsub ../subscript
    cd ../
done

