#!/bin/sh


pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit


zgrep "vasp.[0-9].[0-9].[0-9]* " $pfad | awk '{print $1}' | sed 's|vasp\.||'

