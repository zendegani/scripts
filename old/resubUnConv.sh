#!/bin/bash
set -e
shopt -s expand_aliases
source ~/.bashrc

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . ~/scripts/azfunctions.include;

#checkConvergence.sh -i */OU* | grep unConv.*OUTCAR.gz > unConv.log

createSubmissionScript.sh

here=`pwd`

logFile='unConv.log'
list=`awk '{print $NF}' $logFile | sed 's|/OUTCAR.*||'`
echo $list
read -p "Enter" tmp

#list=`ls -1d [0-9]*`
#list=`ls -1d 1*`

file=INCAR

tags=(NCORE NELM)
tagVals=(10    300)
length=`echo ${#tags[@]}-1|bc`
printf '%20s ' "${tags[@]}";echo
printf '%20s ' "${tagVals[@]}";echo
read -p "Check tags and values, then press Enter" tmp

for j in $list; do
  echo $j
  cd $j
  workClean.sh;
  [[ -e POTCAR ]] && rm -rf POTCAR
#  rm -rf c*  2>/dev/null
  jlnPBEv5.2FeNb_8_11 2>/dev/null
  cp $here/subscript .
  for k in `seq 0 $length`; do
    tag=${tags[$k]}
    tagVal=${tagVals[$k]}
    grep  -q "[^[:alpha:]]$tag[^[:alpha:]]" $file && sed -i "/[^[:alpha:]]$tag[^[:alpha:]]/c\ $tag = $tagVal" $file || echo ' $tag = $tagVal' >> $file
  done
  sbatch ./subscript
  cd $here
done

