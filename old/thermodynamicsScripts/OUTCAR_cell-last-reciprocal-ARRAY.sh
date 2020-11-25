#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -f "$pfad" ] && echo "XXCAR error: $pfad" && exit


number_atoms=`OUTCAR_number_of_atoms.sh $pfad`
einmehr=` expr $number_atoms + 1 `

zip=`file $pfad | sed 's/.*gzip compressed data.*/True/'`
if [ "$zip" = True ];then
    #echo zipped
    zgrep -a --text -A 3 "direct lattice vectors" $pfad | sed 's|--.*||g' | sed '/^ *$/d' | tail -3 | awk '{print $4,$5,$6}'


else
    sed -n -e '/direct lattice vectors/{N;N;N;p}' $pfad | tail -3 | awk '{print $4,$5,$6}'
    #echo unzipped
fi
