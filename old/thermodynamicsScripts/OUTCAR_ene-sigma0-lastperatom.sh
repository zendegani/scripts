#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit


ene=`OUTCAR_ene-sigma0-last.sh $pfad`
#echo ene:$ene
atoms=`OUTCAR_number_of_atoms.sh $pfad`
#echo atoms:$atoms

[ "$ene" = "" ] && echo "----" && exit
[ "$atoms" = "" ] && echo "----" && exit

erg=`echo 1 | awk '{printf "%.8f\n", '"$ene/$atoms"'}'`
echo $erg 


