#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

zgrep LOOP: $pfad | awk '{print $7}' | awk 'BEGIN{size=30} {mod=NR%size; if(NR<=size){count++}else{sum-=array[mod]};sum+=$1;array[mod]=$1;print sum/count}'

