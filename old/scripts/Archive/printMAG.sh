#!/bin/sh

magDirec=${1:-'x'}
OUTCAR=OUTCAR
numatoms=`zgrep -a --text "number of ions     NIONS = " $OUTCAR | awk '{print $12}'`
magLineNum=`echo 5+$numatoms | bc`
zgrep ".*" $OUTCAR  | tac | grep 'magnetization ('$magDirec')' -B$magLineNum -m1 | tac
