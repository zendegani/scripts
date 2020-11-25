#!/bin/sh


pfad=`XXXCAR_link-to-basename.sh $0 $1`
#echo pfad:$pfad 0:$0 1:$1
[ ! -e "$pfad" ] && echo "dne $pfad" && exit

zip=`file $pfad | sed 's/.*gzip compressed data.*/True/'`
if [ "$zip" = True ];then
iteration=`zgrep -a --text "Iteration" $pfad | tail -1 | sed 's|-||g' | sed 's|Iteration||' | sed 's| ||g'`

else
    iteration=`sed -n -e '/Iteration/p' $pfad | tail -1 | sed 's|-||g' | sed 's|Iteration||' | sed 's| ||g'`
fi
[ "$iteration" = "" ] && iteration='---'
echo $iteration
