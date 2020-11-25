#!/bin/bash
#Garch ver 2018.02.01

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

here=`pwd`
createSubmissionScript.sh
read -p "Would you like to normalise universal scaling factor ('lattice constant') to 1.0 ([no]/yes)? " normaliseanswer

#--- Define universal scaling factor ('volume') range
echoblue "Define total volume (written in POSCAR as negative value) and the percentage, recommended +/-10% "
read -p "Equilibrium vol: " volEq

read -p "Minimum volume in percentage [-7] : " minVolP
minVolP=${minVolP:-"-7"}
read -p "Maximum volume in percentage [7] : " maxVolP
maxVolP=${maxVolP:-"7"}
read -p "Volume step in percentage [1] : " stepVolP
stepVolP=${stepVolP:-"1"}
echogreen $volEq $minVolP $maxVolP $stepVolP

percentages=`awk 'BEGIN{ for (i='$minVolP'; i <= '$maxVolP'; i+='$stepVolP') printf("%.4f\n", i); }'`

folders=`ls -1d [0-9]*`
for i in $folders;do
  echored $i
  cd $i
  cp $here/{INCAR,KPOINTS} .
  ln -s /u/alizen/POT/PAW-GGA-PBE_vasp5.2/FeNb_8_11/POTCAR

normaliseanswer=${normaliseanswer:-"no"}
shopt -s nocasematch
[[ "$normaliseanswer" != "no" ]] && poscarLatNormalise || echogreen "Normalisation skipped"
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
    qsub $here/subscript
    cd ../
done
cd $here
done
