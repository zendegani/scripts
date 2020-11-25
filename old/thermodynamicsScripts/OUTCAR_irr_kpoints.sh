#!/bin/sh


pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit


#echo $filename
out=`zgrep -a --text "irreducible k-points:" $pfad | awk 'NR==1{print $2}'`
[ "$out" = "" ] && out=---
echo $out


