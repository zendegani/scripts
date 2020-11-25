#!/bin/bash

pattern="${1:-'./'}"
echo "$pattern"

delFUNC(){
folders=`eval find "$pattern" -name $1 | rev | cut -d/ -f2- | rev`
echo ""
for f in $folders; do
 rm  $f/$1 
done
}

echo "Removing WAVECARs ..."
delFUNC "WAVE*"

echo "Removing CHGCARs ..."
delFUNC "CHGCAR*"

echo "Removing vasprun.xmls ..."
delFUNC "vasprun*"

#echo "Removing POTCARs ..."
#delFUNC "POTCAR*"


