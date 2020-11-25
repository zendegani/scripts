#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
#echo $0 $1
[ ! -e "$pfad" ] && echo "XXCAR error:$pfad:" && exit

#echo pfad: $pfad
#sed -n '/number of ions/p' $pfad | awk '{print $12}'
zgrep -a --text "VOSKOWN" $pfad | head -1 | awk '{print $2}'
