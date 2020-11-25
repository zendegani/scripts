#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit
#echo $pfad
#ls -l $pfad | awk '{print $8,$6,$7}' | sed 's| |-|g'
stat $pfad | grep Modify | awk '{print $2,$3}' | sed 's|\.[0-9]*||g' | sed 's| |_|'


