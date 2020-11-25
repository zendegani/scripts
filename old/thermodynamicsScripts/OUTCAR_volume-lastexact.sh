#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -f "$pfad" ] && echo "XXCAR error: $pfad" && exit



#number_atoms=`OUTCAR_number_of_atoms.sh $pfad`

#cell=`OUTCAR_cell_all.sh $pfad | tail -n 3 | awk '{print $1,"\t",$2,"\t",$3}' | xargs`
cell=`OUTCAR_cell-last-cartesian-ARRAY.sh $pfad | xargs`
#tripleprod3x3.sh $cell 
tripleprod3x3.py $cell 
#tripleprod3x3.sh $cell | awk '{printf "%.5f\n", $1}'
