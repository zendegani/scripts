#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

zgrep LOOP: $pfad | awk '{sum+=$NF} {print $7,sum/NR}' | awk '{print $1}' 

