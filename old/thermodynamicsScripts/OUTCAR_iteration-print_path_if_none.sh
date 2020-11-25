#!/bin/sh

# only if no iteration was performed this script gives the path to the respective folder

pfad=`XXXCAR_link-to-basename.sh $0 $1`
#echo pfad:$pfad 0:$0 1:$1
[ ! -e "$pfad" ] && echo "dne $pfad" && exit
hier=`pwd`

iteration=`zgrep -a --text "Iteration" $pfad | tail -1 | sed 's|-||g' | sed 's|Iteration||' | sed 's| ||g'`
[ "$iteration" != "" ] && echo "" && exit
if [ "$iteration" = "" ];then
    pfadout=`echo $pfad | sed 's|^.||'`
    iterationout=`echo $hier$pfadout`
    echo $iterationout | sed 's|/OUTCAR.*||g'
fi
