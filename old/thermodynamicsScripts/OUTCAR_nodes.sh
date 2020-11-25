#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit


out1=`OUTCAR_nodeslist.sh $pfad`
out2=`echo "$out1" | wc -w | sed 's|[ ]*||g'`
if [ "`isnumber.sh $out1`" != "yes" ];then
    echo $out1
else
    echo $out2
fi
#echo 000: $0 111: $1
#echo 33 $pfad
