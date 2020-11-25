#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

zgrep "executed on" $pfad | awk '{print $5, $6}' | sed 's| |_|g'
