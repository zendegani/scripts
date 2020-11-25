#!/bin/sh

magDirec=${1:-'z'}
folders=`ls -1d [0-9].*`
folder=($folders)
OUTCAR=OUTCAR
numatoms=`zgrep -a --text "number of ions     NIONS = " ${folder[0]}/$OUTCAR | awk '{print $12}'`
magLineNum=`echo 5+$numatoms | bc`

for i in $folders;do
  echo $i
  zgrep ".*" $i/$OUTCAR  | tac | grep 'magnetization ('$magDirec')' -B$magLineNum -m1 | tac
done

echo
echo "Spins along $magDirec axis ..."

for i in $folders;do
 result=`zgrep ".*" $i/$OUTCAR  | tac | grep 'magnetization ('$magDirec')' -B$magLineNum -m1 | tac`
 for j in `seq 1 $numatoms`;  do
   echo "$result" | grep ' '$j' ' | awk '{if ($NF > 0) printf "U"; else printf "D"}'; 
 done
 echo
 zgrep E_p $i/OSZICAR | tail -1

done
