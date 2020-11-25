#!/bin/bash

pfad=`XXXCAR_link-to-basename.sh $0 $1`
#echo $0 $1
[ ! -e "$pfad" ] && echo "XXCAR error:$pfad:" && exit

zip=`file $pfad | sed 's/.*gzip compressed data.*/True/'`
isgz="${pfad: -3}"
if [ "$isgz" = ".gz" ];then
    zip=True
fi
if [ "$zip" == True ];then
    zcat < $pfad | head -20000 | grep -a --text " number of ions     NIONS = " | awk '{print $12}'
else
    head -20000 $pfad | grep -a --text " number of ions     NIONS = " | awk '{print $12}'
fi

#echo pfad: $pfad
#sed -n '/number of ions/p' $pfad | awk '{print $12}'
