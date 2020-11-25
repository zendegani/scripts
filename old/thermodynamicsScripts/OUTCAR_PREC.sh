#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

PREC=`zgrep PREC $pfad | awk '{print $3}'`
echo $PREC
