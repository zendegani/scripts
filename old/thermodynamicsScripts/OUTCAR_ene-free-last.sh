#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit
#echo pfad:$pfad


# check if input file is compressed
zip=`file $pfad | sed 's/.*gzip compressed data.*/True/'`

isgz="${pfad: -3}"
if [ "$isgz" = ".gz" ];then
    zip=True
fi

if [ "$zip" == True ];then
    fre=`zgrep "free energy" $pfad`
else
    fre=`sed -n '/free energy/p' $pfad`

fi


lastline=`echo "$fre" | tail -1`
out=`echo "$lastline" | awk '{print $5}'`
[ "$out" = "energy" ] && out=`echo "$lastline" | awk '{printf "%.8f", $4}'`
echo "$out"


