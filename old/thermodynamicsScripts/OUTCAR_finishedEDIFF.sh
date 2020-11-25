#!/bin/sh
pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

if [ "`zgrep " aborting loop because EDIFF is reached " $pfad | wc -l | sed 's|[ ]*||g'`" = "1" ];then
	echo yes
else
	echo no
fi
