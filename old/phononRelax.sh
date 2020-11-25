#!/bin/bash
set -e 
shopt -s expand_aliases
source ~/.bashrc


# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

#createSubmissionScript.sh
#read -p "Press enter to continue ..."

read -p "Enter supercell dimension, e.g. 2x2x3: " supercel_dim
#supercel_dim="${supercel_dim:-'1x1x1'}"

here=`pwd`
list=`ls -1d [0-9]*`

file=INCAR


for i in $list;do
	echo $i
	cd $i
	mkdir relax
	cp INCAR KPOINTS POSCAR relax/
	cd relax

	echo 'convert POSCAR to strcut'
	sxstructprint --vasp -i POSCAR > struct.sx
	mv POSCAR POSCARorigin

	echo 'generating supercell'
	sxstructrep -r $supercel_dim -i struct.sx -o Sstruct.sx > sxstructrep.log

	echo 'convert Supercell to POSCAR'
	sx2poscar -i Sstruct.sx -o POSCAR > sx2poscar.log

	magmom=`magSuperCell.py`
#	jrepMAG $magmom
	jrepMAGCON $magmom
	tag=NSW
	tagVal=100
	grep  -q "$tag" $file && sed -i "/$tag/c\ $tag=$tagVal" $file || echo '$tag=$tagVal' >> $file
        tag=EDIFFG
        tagVal=-1E-03
        grep  -q "$tag" $file && sed -i "/$tag/c\ $tag=$tagVal" $file || echo '$tag=$tagVal' >> $file
        tag=ISIF
        tagVal=4
        grep  -q "$tag" $file && sed -i "/$tag/c\ $tag=$tagVal" $file || echo '$tag=$tagVal' >> $file
        tag=IBRION
        tagVal=2
        grep  -q "$tag" $file && sed -i "/$tag/c\ $tag=$tagVal" $file || echo '$tag=$tagVal' >> $file
        tag=ISMEAR
        tagVal=1
        grep  -q "$tag" $file && sed -i "/$tag/c\ $tag=$tagVal" $file || echo '$tag=$tagVal' >> $file

	ln -s $here/POTCAR
	cp $here/subscript . 
	sbatch ./subscript
	cd $here
done
