#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

atoms=`OUTCAR_number_of_atoms.sh $pfad`
atomsm1=`echo $atoms | awk '{print $1-1}'`
#echo $atoms
#echo $atomsm1
#exit

# check if input file is compressed
zip=`file $pfad | sed 's/.*gzip compressed data.*/True/'`
isgz="${pfad: -3}"
if [ "$isgz" = ".gz" ];then
    zip=True
fi
if [ "$zip" == True ];then
    #eneref=`zgrep -m 1"free  energy" $pfad | awk '{print $5}'` # > _tmp_file; file=_tmp_file; fi
    ene=`zgrep "free  energy" $pfad | awk '{print $5}'` # > _tmp_file; file=_tmp_file; fi
    eneref=`echo "$ene" | head -1`
    
else
    #eneref=`grep -m 1 "free  energy" $pfad | awk '{print $5}'`
    ene=`sed -n '/free  energy/p' $pfad | awk '{print $5}'`
    eneref=`echo "$ene" | head -1`

fi
#echo "$eneref"
#exit
echo "$ene" | awk '{a='"$eneref"';print ($1-a)*1000/'"$atomsm1"'}' #| tail -n+2

