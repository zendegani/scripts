#!/bin/bash

pattern=$1
SKIP=${2:-'4'}
magDirec=${3:-'z'}
maxY=${4:-'2.5'}

echo $pattern
here=`pwd`
output='conv.dat'
outmag='Magmoms.dat'
folders=`ls -d $pattern`
echo $folders

for i in $folders;do
cd $i

CAR=`ls OUTCAR*`
zgrep 'energy without entropy' $CAR | awk '{print $(NF)}' | cat -n > tmp1
zgrep 'total energy-change' $CAR | awk -F: '{print $2}' | awk '{print $1}'  > tmp2
zgrep 'rms(total)' $CAR | awk '{print $3}' > tmp3
zgrep E_p OSZICAR* | awk '{print $3}' > tmp4
paste tmp1 tmp2 tmp4 tmp3 > $output
rm tmp1 tmp2 tmp3 tmp4
numatoms=`zgrep -a --text "number of ions     NIONS = " $CAR | awk '{print $12}'`
magLineNum=`echo 3+$numatoms | bc`
result=`zgrep ".*" $CAR  | tac | grep 'magnetization ('$magDirec')' -B$magLineNum -m1 | tac`
echo  "$result" | tail -$numatoms | awk '{print $1 " " $NF}' > $outmag

cd $here
done

L=$LINES
C=$COLUMNS
Ep=`for f in $(ls $pattern/OSZICA*); do zgrep E_p $f | tail -1 | awk '{print $NF}' ORS=' '; done`
echo $Ep

gnuplot -e "folders='${folders}';out='${output}'; outmag='${outmag}';COL='${C}'; LIN='${L}';SKIP='${SKIP}'; EP='${Ep}';maxY='${maxY}" /u/alizen/scripts/gnustatus.plg
