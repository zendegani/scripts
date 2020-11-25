#!/bin/bash
#cmmd002 2016.01.06

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
here=`pwd`
echoblue "End members"

folders=`ls -1d [0-9]*`

for f in $folders; do
    echo $f
    cd $f
    cp $root/INCARrelaxEDIFF6NPAR4 INCAR
    cp $root/KPOINTS .
    murnLattice.sh
    cd $here
done

