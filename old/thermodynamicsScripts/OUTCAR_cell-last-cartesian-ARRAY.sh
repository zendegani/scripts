#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -f "$pfad" ] && echo "XXCAR error: $pfad" && exit


number_atoms=`OUTCAR_number_of_atoms.sh $pfad`
einmehr=` expr $number_atoms + 1 `

zip=`file $pfad | sed 's/.*gzip compressed data.*/True/'`
isgz="${pfad: -3}"
if [ "$isgz" = ".gz" ];then
    zip=True
fi
if [ "$zip" = True ];then
    #echo zipped
    zgrep -a --text -A 3 "direct lattice vectors" $pfad | sed 's|--.*||g' | sed '/^ *$/d' | tail -3 | awk '{print $1,$2,$3}'


else
    sed -n -e '/direct lattice vectors/{N;N;N;p}' $pfad | tail -3 | awk '{print $1,$2,$3}'
    #echo unzipped
fi
