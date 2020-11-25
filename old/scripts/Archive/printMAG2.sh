#!/bin/sh

magDirec=${1:-'x'}
OUTCAR=OUTCAR
numatoms=`zgrep -a --text "number of ions     NIONS = " $OUTCAR | awk '{print $12}'`
magLineNum=`echo 5+$numatoms | bc`
result=`zgrep ".*" $OUTCAR  | tac | grep 'magnetization ('$magDirec')' -B$magLineNum -m1 | tac`
echo  "$result"

for i in `seq 1 $numatoms`;  do 
   echo  "$result" | grep ' '$i' ' | awk '{ if ($NF > 0) printf "U"; else printf "D"}'; 
done
echo

