#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit


zip=`file $pfad | sed 's/.*gzip compressed data.*/True/'`
if [ "$zip" = True ];then
    #echo zipped
    tmp=`zgrep "volume of cell :" $pfad | awk '{print $5}'`
else
    tmp=`sed -n -e '/volume of cell :/,+1{s/[0-9]\+/\0/p}' $pfad | awk '{print $5}'`
    #echo unzipped
fi

atoms=`OUTCAR_number_of_atoms.sh $pfad`
echo "$tmp" | tail -1 | awk '{print $1/'"$atoms"'}'
