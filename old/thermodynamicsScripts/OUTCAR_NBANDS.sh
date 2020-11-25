#!/bin/sh
allarg=$*
[ "$allarg" = "" ] && allarg=.
for i in $allarg;do

pfad=`XXXCAR_link-to-basename.sh $0 $i`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit


NBANDS=`zgrep -a --text -s "number of bands    NBANDS" $pfad | sed -n 's/.*NBANDS//p' | awk '{print $2}'`
echo $NBANDS
done
