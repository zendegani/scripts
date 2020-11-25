#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit


zip=`file $pfad | sed 's/.*gzip compressed data.*/True/'`
if [ "$zip" = True ];then
time=`zgrep "LOOP:" $pfad | awk '{sum+=$NF} {print $7,sum/NR}' | awk '{printf "%.2f\n",$2}' | tail -1`
else
time=`sed -n -e '/LOOP:/p' $pfad | awk '{sum+=$NF} {print $7,sum/NR}' | awk '{printf "%.2f\n",$2}' | tail -1`
fi


[ "$time" = "" ] && time=---
echo $time


#zgrep LOOP: $pfad | awk '{sum+=$NF} {print $7,sum/NR}' | awk '{printf "%.2f\n",$2}' | tail -1
