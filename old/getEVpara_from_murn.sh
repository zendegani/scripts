#!/bin/bash

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;


file=${1:-'murn.dat'}

E0=`awk 'FNR==4 {print $NF}' $file`
V0=`awk 'FNR==5 {print $NF}' $file`
B0=`awk 'FNR==2 {print $(NF-1)}' $file`
Bp=`awk 'FNR==3 {print $NF}' $file`

echogreen " Hartree      Bohrradius^3   B0 GPa     bulk modulus derivative B0'"
echo $E0"     "$V0"     "$B0"  "$Bp

V0_Ang=` echo "scale=5;0.14818471*$V0"|bc `
E0_meV=` echo "scale=5;27211.385*$E0"|bc `

echoblue " meV          Angstrom^3     B0 GPa     bulk modulus derivative B0'"
echo $E0_meV"  "$V0_Ang"    "$B0"  "$Bp

