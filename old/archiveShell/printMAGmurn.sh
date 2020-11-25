#!/bin/sh

magDirec=${1:-'x'}
folders=`ls -1d [0-9].*`
folder=($folders)
OUTCAR=OUTCAR
numatoms=`zgrep -a --text "number of ions     NIONS = " ${folder[0]}/$OUTCAR | awk '{print $12}'`
magLineNum=`echo 5+$numatoms | bc`

for i in $folders;do
  echo $i
  zgrep ".*" $i/$OUTCAR  | tac | grep 'magnetization ('$magDirec')' -B$magLineNum -m1 | tac
done

