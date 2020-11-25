#!/bin/bash
#Garch ver 2017.06.13

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

createSubmissionScript.sh

#--- prepare POSCAR for Murn (normalising the lattice index to 1.0)
echoblue "This is the POSCAR header"
echored "----------------------"
head POSCAR
echored "----------------------"
#--- Define universal scaling factor ('lattice constant') range
z3rd=`awk 'NR==5 {print $NF}' POSCAR`
read -p "Define original c (3rd index of Z vector in POSCAR) and the percentage, recommended +/-5% : " origianl_z
origianl_z=${origianl_z:-"$z3rd"}
echogreen $origianl_z
read -p "Range start in percentage [-5] : " rangestart
rangestart=${rangestart:-"-5"}
read -p "Range end in percentage [5] : " rangeend
rangeend=${rangeend:-"5"}
read -p "Range step in percentage [1] : " rangestep
rangestep=${rangestep:-"1"}
echogreen $rangestart $rangestep $rangeend

percentages=`awk 'BEGIN{ for (i='$rangestart'; i <= '$rangeend'; i+='$rangestep') printf("%.4f\n", i); }'`

for p in $percentages; do
    c=`echo "scale=10;$origianl_z*(100+$p)/100" | bc`
    #--- prompt user info
    echogreen "-------------------------------------------------------"
    echogreen "  c  = $c   Percentage: $p"
    echogreen "-------------------------------------------------------"
    mkdir $c
    cd $c

    cp ../INCAR ./
    cp ../KPOINTS ./
    ln -s ../POTCAR 
    cp ../POSCAR ./
z_ab=`awk 'NR==5 {print $(NF-2) " " $(NF-1)}' POSCAR`
#--- create POSCAR
    mv POSCAR POSCARtmp
    head -4 POSCARtmp > POSCAR
    cat >> POSCAR << POSCAReof
   $z_ab   $c
POSCAReof
    tail -n +6 POSCARtmp >> POSCAR
    qsub ../subscript
    cd ../
done

