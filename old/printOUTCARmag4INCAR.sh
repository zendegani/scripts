#!/bin/bash

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

natoms=`getAtomsNr OUTCAR`
tableX=`printMagnetizationTableNoHeader x OUTCAR`
tableXLastCol=($(echo "$tableX" | awk '{print $NF}'))
tableY=`printMagnetizationTableNoHeader y OUTCAR`
tableYLastCol=($(echo "$tableY" | awk '{print $NF}'))
tableZ=`printMagnetizationTableNoHeader z OUTCAR`
tableZLastCol=($(echo "$tableZ" | awk '{print $NF}'))
for ((i=0; i<$natoms; i++)); do
    echo -e "${tableXLastCol[$i]} ${tableYLastCol[$i]} ${tableZLastCol[$i]} \c"
done