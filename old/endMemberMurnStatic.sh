#!/bin/bash
#cmmd002 2016.01.10

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
    cd $f/010-murn

    hereMurn=`pwd`
    foldersMurn=`ls -1d [0-9]*.*`
    for i in $foldersMurn;do
        cd $i
        echored $i
        workcontinueCONTCAR.sh
        rm POTCAR
        ln $hereEM/$f/POTCAR
        cp $root/INCARstaticEDIFF6NPAR2 INCAR
        qsub -pe 'mpi*' 24 $HOME/scripts/jsub_pa_5_2.sh
        cd $hereMurn
    done
    cd $hereEM
done
