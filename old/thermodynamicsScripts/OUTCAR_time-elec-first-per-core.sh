#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

time=`OUTCAR_time-elec-first-.sh $pfad`
cores=`OUTCAR_cores.sh $pfad`
echo "$time $cores" | awk '{print $1*$2}'
