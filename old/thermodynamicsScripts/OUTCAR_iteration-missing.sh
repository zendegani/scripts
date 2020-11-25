#!/bin/sh


pfad=`XXXCAR_link-to-basename.sh $0 $1`
#echo pfad:$pfad 0:$0 1:$1
[ ! -e "$pfad" ] && echo "dne $pfad" && exit


iteration=`zgrep -a --text "Iteration" $pfad | sed 's|(.*||g' | uniq | sed 's|.*Iteration||' | awk '{print $1-NR,$1,NR}' | sed 's|^0.*||' | sed '/^$/d' | head -1 | awk '{print $3}'`
[ "$iteration" = "" ] && iteration='none_missing'
echo $iteration
