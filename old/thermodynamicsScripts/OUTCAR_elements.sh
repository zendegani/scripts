#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
#echo $0 $1
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

#echo pfad: $pfad
zgrep POTCAR: $pfad | awk '{print $3}' | xargs | awk '{for (i=1;i<=NF/2-1;i++) printf "%s-",$i; printf "%s",$(NF/2)}'

