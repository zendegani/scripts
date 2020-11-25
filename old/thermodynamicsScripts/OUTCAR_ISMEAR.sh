#!/bin/sh
pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

zgrep ISMEAR $pfad | awk '{print $3}' | sed 's|;||'

