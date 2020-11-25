#!/bin/bash

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;


checkConvergence.sh > log_checkConvergence.log &
checkNBANDS.sh > log_checkNBANDS.log &
OUTCAR_A.sh OUTCAR_ene-sigma0-lastperatom__mod.sh OUTCAR_volume-lastperatom__mod.sh OUTCAR_number_of_atoms__mod.sh OUTCAR_ene-sigma0-last.sh OUTCAR_volume-last.sh OUTCAR_iteration-max.sh OUTCAR_cores.sh OUTCAR_time-hour.sh OUTCAR_time-elec-mean-.sh > log_details.log &
printMagSelective.sh -d 2 -c 16 > log_printMagSelective.log &



here=`pwd`
list=`ls -1d [0-9]*`
for i in $list ; do echo $i; cd $i; printMagSelective.sh -s moments.dat ; cd $here;done


getEnergyVsFolders_Ep.sh

sed -i 's/_/  /g' Folder_eV.dat 

