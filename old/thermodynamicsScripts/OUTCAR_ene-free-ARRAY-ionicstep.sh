#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit



# check if input file is compressed
zip=`file $pfad | sed 's/.*gzip compressed data.*/True/'`
isgz="${pfad: -3}"
if [ "$isgz" = ".gz" ];then
    zip=True
fi
if [ "$zip" == True ];then
    ene=`zgrep "free  energy" $pfad | awk '{print $5}'` # > _tmp_file; file=_tmp_file; fi
    
else
    ene=`sed -n '/free  energy/p' $pfad | awk '{print $5}'`

fi
echo "$ene"

