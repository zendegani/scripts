#!/bin/sh
pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

ENCUT=`zgrep -a --text "ENCUT " $pfad | awk '{print $3}'`
echo $ENCUT

