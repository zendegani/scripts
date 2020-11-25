#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit


#zip=`file $pfad | sed 's/.*gzip compressed data.*/True/'`
tmp=`zgrep "volume of cell :" $pfad | awk '{print $5}'`
#if [ "$zip" = True ];then
#    #echo zipped
#    tmp=`zgrep "volume of cell :" $pfad | awk '{print $5}'`
#else
#    tmp=`grep "volume of cell :" $pfad | awk '{print $5}'`
#    #tmp=`sed -n -e '/volume of cell :/,+1{s/[0-9]\+/\0/p}' $pfad | awk '{print $5}'`
#    #echo unzipped
#fi

echo "$tmp" | tail -1
