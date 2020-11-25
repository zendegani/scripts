#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

#zgrep -a --text "Fermi-smearing in eV" $pfad | awk '{print $6,$6*11604.506}'
kB=11604.5059554883246
ene=`OUTCAR_ene-inner-last.sh $pfad` 
enesig=`OUTCAR_ene-sigma0-last.sh $pfad`
fre=`OUTCAR_ene-free-last.sh $pfad`
#echo ene:$ene
#echo sig:$enesig
#echo fre:$fre
out=`echo 1 | awk '{printf("%.2f",(('"$ene"'*-1)-('"$enesig"'*-1))*1000/2)}'`
#out2=`echo 1 | awk '{print (('"$fre"'*-1)-('"$enesig"'*-1))*1000/2}'`
## in VASP is out always out2 because sigma0 is exactly (defined) inbetween out and out2  (test)h
echo $out #$out2
