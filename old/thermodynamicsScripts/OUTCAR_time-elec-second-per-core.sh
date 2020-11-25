#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

time=`OUTCAR_time-elec-second-.sh $pfad`
[ "`isnumber.sh $time`" != "yes" ] && echo --- && exit
#echo isnumber:$time:
cores=`OUTCAR_cores.sh $pfad`
echo "$time*$cores" | bc -l
