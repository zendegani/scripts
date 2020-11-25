#!/bin/bash
set -e
shopt -s expand_aliases
source ~/.bashrc

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . ~/scripts/azfunctions.include;

here=`pwd`
logFile='FULL.log'
list=`awk '{print $1}' $logFile | sed 's|/OUTCAR.*||'`
echo $list
read -p "Enter" tmp

#list=`ls -1d [0-9]*`
#list=`ls -1d 1*`

file=INCAR
NBANDS=610
read -p "NBANDS=$NBANDS" tmp
#LAMBDA=150

for j in $list; do
  echo $j
  cd $j
  workClean.sh;
  [[ -e POTCAR ]] && rm -rf POTCAR
  rm -rf c*  2>/dev/null
  jlnPBEv5.2FeNb_8_11 2>/dev/null
  cp $here/subscript .
#  ln -s ../../forces_background/WAVECAR
  tag=NBANDS
  tagVal=$NBANDS
  grep  -q "$tag" $file && sed -i "/$tag/c\ $tag=$tagVal" $file || echo '$tag=$tagVal' >> $file
#  tag=LAMBDA
#  tagVal=$LAMBDA
#  grep  -q "$tag" $file && sed -i "/$tag/c\ $tag=$tagVal" $file || echo '$tag=$tagVal' >> $file
  sbatch ./subscript
  cd $here
done
