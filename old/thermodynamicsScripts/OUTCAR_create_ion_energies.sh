#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit
 #echo pfad: $pfad

## check if correct ion_energies is written
## check if correct ion_energies is written
ion_energies=`echo $pfad | sed 's|OUTCAR.*|ion_energies|'`
[ -e "$ion_energies" ] && [ "`head -1 $ion_energies | wc -w | sed 's|[ ]*||g'`" = "12" ] && [ "`zgrep -a --text "free  en" $pfad  | wc -l | sed 's|[ ]*||g'`" = "`tail -1 $ion_energies | awk '{print $1}'`" ] && exit

## nions is needed to scale to (meV/atom) for dUdL
## nions is needed to scale to (meV/atom) for dUdL
nions=`zgrep -a --text " number of ions     NIONS = " $pfad | awk '{print $12}'`
[ "$nions" = "" ] && echo OUTCAR seems to be corrupted && exit
nionsm1=` expr $nions - 1 `
  #echo N:$nions N-1:$nionsm1


## get seed when is in path
## get seed when is in path
pfadseed=$pfad; [ "`echo $pfadseed | grep "/" | wc -w | sed 's|[ ]*||g'`" = "0" ] && pfadseed=`pwd`
#echo pfads: $pfadseed
seed=`echo $pfadseed | sed -n 's|.*lambda\([0-9.]*\)_\([0-9]*\).*|\2|p'`
[ "$seed" = "" ] && seed="-----"


## delete old ion_energies
## delete old ion_energies
rm -f $ion_energies

## get ion_energies
## get ion_energies
zgrep -a --text "free  en\|energy  w" $pfad | xargs -n 13 | \
awk 'NR==1{free=$5;ewe=$10;es0=$13}{printf "%s  %.2f  %.2f  %.2f  %s %s  %s %s %s %s %s %s\n", \
NR,1000*($5-free)/'$nionsm1',1000*($10-ewe)/'$nionsm1',1000*($13-es0)/'$nionsm1','$seed',NR,$5,$10,$13,free,ewe,es0}' > $ion_energies
