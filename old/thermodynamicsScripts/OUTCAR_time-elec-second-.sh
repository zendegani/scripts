#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit


out=`zgrep "LOOP:" $pfad |  sed -n '2p' | sed 's|.*time||'`
[ "$out" = "" ] && out=---
echo $out

