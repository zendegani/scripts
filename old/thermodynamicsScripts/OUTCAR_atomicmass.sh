#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

mass=`zgrep -a --text "POMASS =   " $pfad | awk '{print $3}' | sed 's|;||g'`
[ "$mass" = "" ] && mass=---
echo $mass

