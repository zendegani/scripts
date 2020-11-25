#!/bin/bash

SKIP=${1:-'4'}
CAR=`ls OUTCAR*`
zgrep 'energy without entropy' $CAR | awk '{print $(NF)}' | cat -n > tmp1
zgrep 'total energy-change' $CAR | awk -F: '{print $2}' | awk '{print $1}'  > tmp2
zgrep 'rms(total)' $CAR | awk '{print $3}' > tmp3
zgrep E_p OSZICAR* | awk '{print $3}' > tmp4
paste tmp1 tmp2 tmp4 tmp3 > conv.dat
rm tmp1 tmp2 tmp3 tmp4
L=$LINES
C=$COLUMNS
gnuplot -e "filename='conv.dat'; COL='${C}'; LIN='${L}';SKIP='${SKIP}'" $HOME/scripts/gnuconv5skip.plg


