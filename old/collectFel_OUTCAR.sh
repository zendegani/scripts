#!/bin/bash

#list=`ls -1d 0* 1.0[0-2]*`
list=`ls -1d [0-9]*`
here=`pwd`
dest=$here/Fel
[[ -d $dest ]] || mkdir $dest
echo $dest

for i in $list ; do 
	echo $i; 
	if [[ -d $i/el ]]; then
		cd $i/el/0.01;
		vol=`OUTCAR_volume-lastperatom.sh` ; 
		cd $here/$i/el/; 
		listj=`ls -1d 0*`;
		echo $listj;
		for j in $listj; do
			cp $j/OUTCAR.gz $dest/OUTCAR.$vol\_$j.gz
		done
		cd $here;
	fi
done
