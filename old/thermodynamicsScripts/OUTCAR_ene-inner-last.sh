#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit
#echo $pfad
# check if input file is compressed
zip=`file $pfad | sed 's/.*gzip compressed data.*/True/'`


isgz="${pfad: -3}"
if [ "$isgz" = ".gz" ];then
    zip=True
fi
if [ "$zip" == True ];then
    ene=`zgrep "energy without entropy" $pfad` 
    
else
    ene=`sed -n '/energy without entropy/p' $pfad`

   # fre=`zgrep "free energy" $pfad | tail -1 | awk '{print $5}'`
fi


lastline=`echo "$ene" | tail -1`
out=`echo "$lastline" | awk '{print $5}'`
[ "$out" = "energy" ] && out=`echo "$lastline" | awk '{printf "%.8f", $8}'`
echo "$out"
