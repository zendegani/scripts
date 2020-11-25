#!/bin/bash

here=`pwd`

read -p  "Enter source root path: " path

echo $path

file=OUTCAR.gz
eval cd $path
list=`ls -1d */thermo/thermo.out`
template="Fqh_fromMeshFreqs_"

for i in $list; do
  echo $i
  IFS='/' read -ra ADDR <<< "$i"
  echo "${ADDR[@]}"
  echo $path/"${ADDR[0]}"/forces_background/OUTCAR.gz
  if [[ -f "`eval echo $path/${ADDR[0]}/forces_background/$file`" ]] 
  then
    echo YES
    eval cd $path/${ADDR[0]}/forces_background
    vol=`OUTCAR_volume-lastperatom.sh`
    fileThermo=`eval echo $path/${ADDR[0]}/thermo/thermo.out`
    cp $fileThermo $here/$template$vol
    cd $here
  else
    echo No
  fi
done
