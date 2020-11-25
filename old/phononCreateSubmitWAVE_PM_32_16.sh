#!/bin/bash
#2016-01-06

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

createSubmissionScript.sh

root4WAVE="/cmmc/ptmp/alizen/C14/finit03/WAVECARprep/L35"

echo 'convert POSCAR to strcut'
sxstructprint --vasp -i POSCAR > struct.sx

echo 'generating supercell'
sxstructrep -r $1 -i struct.sx -o Sstruct.sx > sxstructrep.log

echo 'convert Supercell to POSCAR'
sx2poscar -i Sstruct.sx -o SPOSCAR > sx2poscar.log

echo 'generating displacements'
sxuniqdispl -d 0.02 -i Sstruct.sx > sxuniqdispl.log

echo 'making forces background folder'
mkdir forces_background
cp SPOSCAR forces_background/POSCAR
cd forces_background
cp ../INCAR .
cp ../KPOINTS .
ln -s ../POTCAR
ln -s $root4WAVE/WAVECAR
#ln $root4WAVE/CHGCAR

sed -i '6s/.*/ 32  16 /' POSCAR
qsub -N JbackF ../subscript
cd ..


echo 'generating folders and submitting jobs'
ndir=`ls -1d i*.* | wc -l`
for (( i=1; i<$ndir+1; i++ )); do 
    echo $i
    echo 1_$i
    sx2poscar -i input-disp-$i.sx -o SPOSCAR$i >> sx2poscar.log
    mkdir 1_$i
    mv SPOSCAR$i 1_$i/POSCAR
    cd 1_$i
    cp ../INCAR .
    cp ../KPOINTS .
    ln -s ../POTCAR
    ln -s $root4WAVE/WAVECAR
 #   ln $root4WAVE/CHGCAR
    sed -i '6s/.*/ 32  16 /' POSCAR
    qsub  -N J$i ../subscript
    cd ..
done

