#!/bin/bash

vol=`head finite/thermo/thermo.out | grep 'vol are' | awk '{print $4}'`
echo $vol

#for i in $(seq 0.01 .01 .1)
#do
cd elec
perm=`ls -1d [0-9]*`
for j in $perm;do
cp $j/OUTCAR.gz ../../OUTCARs/OUTCAR.$vol'_'$j.gz
done

