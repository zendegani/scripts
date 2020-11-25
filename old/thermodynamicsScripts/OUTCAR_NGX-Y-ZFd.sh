#!/bin/sh
allarg=$*
[ "$allarg" = "" ] && allarg=.
for arg in $allarg;do
pfad=`XXXCAR_link-to-basename.sh $0 $arg`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

NGXFd=`zgrep "dimension x,y,z NGXF=" $pfad | awk '{print $4,$6,$8}'`
echo $NGXFd | sed 's| |-|g'
done
