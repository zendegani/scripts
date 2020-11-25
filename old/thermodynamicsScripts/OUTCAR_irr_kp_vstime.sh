#!/bin/sh
pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit
######### define path #################################################
######### just copy this ##############################################
#file=`basename $0`
#echo weiter:$file $1
#pfad=`OUTCAR_pfad.sh $file $1`
#echo pfadskript:$pfad
########################################################################
########################################################################

#echo $filename
irrkp=`OUTCAR_irr_kpoints.sh $pfad`
#echo irr:$irrkp
zeit=`OUTCAR_time-.sh $pfad`
#echo zeit:$zeit
out=`echo $zeit/$irrkp | bc -l`
#grep "irreducible k-points:" $pfad | awk '{print $2}'
echo "$out" | awk '{printf("%.1f",$1)}'


