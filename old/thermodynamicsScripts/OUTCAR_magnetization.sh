#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

atoms=`OUTCAR_number_of_atoms.sh $pfad`
zip=`file $pfad | sed 's/.*gzip compressed data.*/True/'`
if [ "$zip" = True ];then
time=`zgrep "number of electron" $pfad | tail -1 | awk '{print $NF/'"$atoms"'}'`
else
time=`sed -n -e '/number of electron/p' $pfad | tail -1 | awk '{print $NF/'"$atoms"'}'`
fi


[ "$time" = "" ] && time=---
echo $time

