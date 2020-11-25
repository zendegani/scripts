#!/bin/bash
#2017.03.02

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

here=`pwd`
echo "$here"

read -p "This script should run on top folder of end-members. Press enter to continue ..."

file=sum.out
perm=`ls -1d [0-9]* | sort -n`

echo "Conf 3j1 3j2 3k1 3k2 : Energy_eV | Volume_A^3 | Bulk modulus_GPa" >> $file
#     Q-3- Al  Al  Al  Mg  : -0.129106   121.229926   71.055986

for j in $perm;do
cd $j/murn
echo "$j"

murn=murn.dat
POSCAR=POSCAR

B0=`grep --text "bulk modulus B0" $murn | tail -1 | awk '{print $6}'`
E0_Hartree=`grep --text "minimum energy E0" $murn | tail -1 | awk '{print $6}'`
V0_Bohr=`grep --text "optimal volume V0" $murn | tail -1 | awk '{print $6}'`

E0_eV=` echo "scale=7;$E0_Hartree/0.036749309"|bc `
V0_A3=` echo "scale=6;$V0_Bohr/6.74833304162"|bc `

phase=`head -1 ../$POSCAR`

cd $here
echo "$phase  : $E0_eV   $V0_A3   $B0" >> $file

done


