#!/bin/bash
#2016-06-02

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

read -p "Enter the maximum temperature in K, e.g. 2001: " maxT
maxT="${maxT:-2001}"

read -p "Enter the temperature steps in K, e.g. 1: " Tstep 
Tstep="${Tstep:-1}"

echoblue "Maximum temperature $maxT K"
echoblue "Temperature steps $Tstep K"
read -p "Press enter to continue ..."

echogreen "Extract forces"
get_sxdynmat.sx
mkdir thermo
cd thermo
echogreen "Get dynmat"
sxdynmat -i ../sxdynmat.sx -H > sxdynmat.log
#for phono use qPath in primitiv basis and for thermo use grid as input
echogreen "Get phonon"
sxphonon -s ~/scripts/phononSet_thermo.sx > sxphonon.log
echogreen "Get free energy"
sxthermo -T $maxT -dT $Tstep -p phonon.sxb > sxthermo.log
