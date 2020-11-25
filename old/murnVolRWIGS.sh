#!/bin/bash
#Garch ver 2017.06.13

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

createSubmissionScript.sh

#--- prepare POSCAR for Murn (normalising the lattice index to 1.0)
echogreen "This is the POSCAR header"
echogreen "----------------------"
head POSCAR
echogreen "----------------------"
read -p "Would you like to normalise universal scaling factor ('lattice constant') to 1.0 ([no]/yes)? " normaliseanswer
normaliseanswer=${normaliseanswer:-"no"}
shopt -s nocasematch
[[ "$normaliseanswer" != "no" ]] && poscarLatNormalise || echogreen "Normalisation skipped"
shopt -u nocasematch

#--- Define universal scaling factor ('volume') range
echoblue "Define total volume (written in POSCAR as negative value) and the percentage, recommended +/-10% "
read -p "Equilibrium vol: " volEq

read -p "Minimum volume in percentage [-5] : " minVolP
minVolP=${minVolP:-"-5"}
read -p "Maximum volume in percentage [5] : " maxVolP
maxVolP=${maxVolP:-"5"}
read -p "Volume step in percentage [1] : " stepVolP
stepVolP=${stepVolP:-"1"}
echogreen $volEq $minVolP $maxVolP $stepVolP

percentages=`awk 'BEGIN{ for (i='$minVolP'; i <= '$maxVolP'; i+='$stepVolP') printf("%.4f\n", i); }'`

RWIGflag=false
read -p "Would you like to modify RWIGS ([no]/yes)? " RWIGSanswer
RWIGSanswer=${RWIGSanswer:-"no"}
shopt -s nocasematch
if [[ "$RWIGSanswer" == "yes" ]] || [[ "$RWIGSanswer" == "y" ]]; then
    RWIGflag=true
    echogreen "For each atom at volume $volEq provide the RWIGS value."
    read -p "Enter the number of atoms : " n
    for r in `seq $n`; do
        read -p "Enter the RWIGS for atom #$r: " RWIGS[$r]
    done
fi
shopt -u nocasematch


for p in $percentages; do
    v=`echo "scale=4;$volEq*(100+$p)/100" | bc`
    #--- prompt user info
    echogreen "-------------------------------------------------------"
    echogreen "  Vol  = $v   Percentage: $p"
    echogreen "-------------------------------------------------------"
    mkdir $v
    cd $v

    cp ../INCAR ./
    cp ../KPOINTS ./
    ln -s ../POTCAR 
    cp ../POSCAR ./

#--- create POSCAR
    mv POSCAR POSCARtmp
    head -1 POSCARtmp > POSCAR
    cat >> POSCAR << POSCAReof
-$v
POSCAReof
    tail -n +3 POSCARtmp >> POSCAR
    if $RWIGflag; then
        RWIGSfactor=`awk 'BEGIN {print ((100+'$p')/100)^.333334}' /dev/null`
        for r in `seq $n`; do
            value[$r]=`echo "scale=4;${RWIGS[$r]}*$RWIGSfactor/1" | bc`
        done
        echogreen "RWIGS(s) increase/decrease factor: $RWIGSfactor"
        newRWIGS=`echo "${value[@]:1:$n}"  \!"radius of wigner-seitz "`
        substINCARtagVALUE RWIGS $newRWIGS
    fi
    qsub ../subscript
    cd ../
done

