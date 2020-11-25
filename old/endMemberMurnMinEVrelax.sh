#!/bin/bash
#cmmd002 2016.01.11

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

#createSubmissionScript.sh

#--- prepare POSCAR for Murn (normalising the lattice index to 1.0)
#poscarLatNormalise

root=`pwd`
echoblue "Root:"
echo $root
cd 'Q-Al-Mg'
hereEM=`pwd`
echoblue "End members"

foldersEM=`ls -1d [0-9]*`

for f in $foldersEM; do
    echo "############################" $f
    cd $f/; 
    mkdir 021-relaxMinEV; 
    cd 021-relaxMinEV; 
    cp ../010-murn/POSCARfinite POSCAR; 
    cp $root/INCARrelaxEDIFF8NPAR4 INCAR; 
    cp $root/KPOINTS .; 
    ln ../POTCAR; 
    qsub -pe 'mpi*' 24 $HOME/scripts/jsub_pa_5_2.sh; 
    cd $hereEM; 
done
