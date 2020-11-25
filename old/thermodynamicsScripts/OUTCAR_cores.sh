#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit


nodes=`zgrep -a --text "running on" $pfad | awk '{print $3}'`
[ "$nodes" = "" ] && serial=`zgrep -a --text "serial version" $pfad` && [ "`echo $serial | wc -w | sed 's|[ ]*||g'`" = "2" ] && nodes=1
[ "$nodes" = "" ] && nodes="--"
echo $nodes
