#!/bin/bash
shopt -s expand_aliases
source ~/.bashrc

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . ~/scripts/azfunctions.include;

createSubmissionScript.sh

here=`pwd`
list=`ls -1d [0-9]*`

file=INCAR
folder="el2"

tags=(NCORE NELM ISMEAR LAMBDA NBANDS)
tagVals=(10 750  -1     150    600)
length=`echo ${#tags[@]}-1|bc`
printf '%20s ' "${tags[@]}";echo
printf '%20s ' "${tagVals[@]}";echo
read -p "Check tags and values, then press Enter" tmp

for j in $list; do
  read -p $j tmp
  cd $j
  [[ -d $folder ]] || mkdir $folder
  cp KPOINTS INCAR $folder/
  cd $folder/
  cp ../forces_background/CONTCAR POSCAR
  jlnPBEv5.2FeNb_8_11 2>/dev/null
  cp $here/subscript .
  for k in `seq 0 $length`; do
    tag=${tags[$k]}
    tagVal=${tagVals[$k]}
    grep  -q "[^[:alpha:]]$tag[^[:alpha:]]" $file && sed -i "/[^[:alpha:]]$tag[^[:alpha:]]/c\ $tag = $tagVal" $file || echo ' $tag = $tagVal' >> $file
  done
  SIGMA.sh
  cd $here
done
