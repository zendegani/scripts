#!/bin/bash

OUTCAR="OUTCAR"
CONTCAR="CONTCAR"
murn="murn.dat"
folder="${1:-'1.00'}" 
POSCARtmp=POSCARtmp
POSCARfinite=POSCARfinite

here=`pwd`
echo "$here"

volbohr3=`zgrep --text "optimal volume V0" $murn | awk {'print $6'}`
cd $folder
numatoms=`zgrep -a --text "number of ions     NIONS = " $OUTCAR | awk '{print $12}'`
volang3=` echo "scale=8;$numatoms*0.14818471*$volbohr3"|bc `
cd $here
cp $folder/$CONTCAR $POSCARtmp
POSnLines=`cat -n $POSCARtmp | tail -1 | awk '{print $1}'`
n=`echo $POSnLines-2 | bc`
head -1 $POSCARtmp > $POSCARfinite
cat >> $POSCARfinite << POSCAReof
    -$volang3
POSCAReof
tail -$n $POSCARtmp >> $POSCARfinite 
