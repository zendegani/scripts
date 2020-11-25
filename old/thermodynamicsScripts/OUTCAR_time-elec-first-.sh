#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

zip=`file $pfad | sed 's/.*gzip compressed data.*/True/'`
if [ "$zip" = True ];then
time=`zgrep "LOOP:" $pfad | head -1 | sed 's|.*time||'`
else
time=`sed -n -e '/LOOP:/p' $pfad | head -1 | sed 's|.*time||'`
fi


[ "$time" = "" ] && time=---
echo $time

