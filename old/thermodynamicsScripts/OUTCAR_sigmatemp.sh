#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit


kB=11604.5059554883246
sigma=`OUTCAR_sigma.sh $pfad`
#zgrep -a --text "Fermi-smearing in eV" $pfad | awk '{print $6,$6*11604.506}'
out=`echo $sigma | awk '{printf "%.10f\n", $1*'"$kB"'}'`
#zgrep -a --text "Fermi-smearing in eV" $pfad | awk '{printf "%.10f\n", $6*'"$kB"'}'`
[ "$out" = "" ] && out=--- && echo $out && exit
echo "$out" | awk '{printf("%.1f",$1)}'
