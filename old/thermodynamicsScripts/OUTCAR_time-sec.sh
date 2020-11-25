#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

ttime_hours=`zgrep -a --text " Total CPU time used (sec):" $pfad | awk 'NR==1{printf("%.1f",$6/1)}'`
[ "$ttime_hours" == "" ] && ttime_hours=----

echo $ttime_hours

