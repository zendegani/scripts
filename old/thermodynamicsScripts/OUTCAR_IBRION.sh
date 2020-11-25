#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit
var=`echo $0 | sed 's|.*/||' | sed 's|^OUTCAR_||' | sed 's|.sh||'`
#echo vv:$var
zgrep ".*" $pfad | grep $var | awk '{print $3}'
