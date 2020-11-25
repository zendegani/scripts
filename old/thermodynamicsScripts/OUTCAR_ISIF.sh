#!/bin/sh
pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

zgrep -a --text ISIF $pfad | awk '{print $3}' 

