#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit


#ene=`zgrep "energy  without entropy" $pfad | awk '{print $7}'`
#echo ene:$ene
#atoms=`OUTCAR_number_of_atoms.sh $pfad`
#echo atoms:$atoms
#ene=`zgrep "energy  without entropy" $pfad | tail -1 | awk '{print $7/$atoms}'`

# check if input file is compressed
zip=`file $pfad | sed 's/.*gzip compressed data.*/True/'`
isgz="${pfad: -3}"
if [ "$isgz" = ".gz" ];then
    zip=True
fi
if [ "$zip" == True ];then
    ene=`zgrep "energy  without entropy" $pfad | awk '{print $7}'` # > _tmp_file; file=_tmp_file; fi
    
else
    ene=`sed -n '/energy  without entropy/p' $pfad | awk '{print $7}'`

fi
echo "$ene"

