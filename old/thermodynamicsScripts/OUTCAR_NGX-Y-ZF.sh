#!/bin/sh
allarg=$*
[ "$allarg" = "" ] && allarg=.
for arg in $allarg;do
    pfad=`XXXCAR_link-to-basename.sh $0 $arg`
    [ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit
    
    NGXF=`zgrep "support grid    NGXF=" $pfad | awk '{print $4,$6,$8}'`
    echo $NGXF | sed 's| |-|g'
done

