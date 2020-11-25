#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit


#zeit=`OUTCAR_time-sec.sh $pfad`
zeit=`OUTCAR_time-elec-mean-.sh $pfad`
nodes=`OUTCAR_cores.sh $pfad`
#echo zeit $zeit
#echo nodes $nodes
#exit
#out=`echo $zeit/$nodes | bc -l`
#echo "$out" | awk '{printf("%.2f\n",$1)}'
echo $zeit $nodes | awk '{printf "%.2f\n", $1*$2/25376*100*19.230769231}'
