#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

#zgrep -a --text "Fermi-smearing in eV" $pfad | awk '{print $6,$6*11604.506}'
#zgrep ";   SIGMA  =" $pfad | awk '{print $7}'
zgrep -a --text ";   SIGMA  =" $pfad | awk '{print $6}'

#grep -n ";   SIGMA  =" 3.7Ang/OUTCAR.gz | awk '{print $7}'


