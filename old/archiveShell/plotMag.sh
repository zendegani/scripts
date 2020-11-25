#!/bin/sh

magDirec=${1:-'z'}
maxY=${2:-'3'}
OUTCAR=OUTCAR
numatoms=`zgrep -a --text "number of ions     NIONS = " $OUTCAR | awk '{print $12}'`
magLineNum=`echo 3+$numatoms | bc`
result=`zgrep ".*" $OUTCAR  | tac | grep 'magnetization ('$magDirec')' -B$magLineNum -m1 | tac`
echo  "$result" | tail -$numatoms | awk '{print $1 " " $NF}' > Magmoms.dat

L=$LINES
C=$COLUMNS
gnuplot -e "COL='${C}'; LIN='${L}';maxY='${maxY}'" $HOME/scripts/gnumagmoms.plg


