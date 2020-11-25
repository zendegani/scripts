#!/bin/bash
#ver 2016.07.13

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

switches="[-i inputFOLDERS] [-d DEPTH] [-t TITLE] [-s SKIP] [-h] [-r] "
while getopts "d:s:t:i:hr" opt; do
  case $opt in
    r)
      rms="skip"
      echo "Skip the rms plot." >&2
      ;;
    s)
      SKIP=$OPTARG
      echo "Skip the $SKIP rows from the beginning." >&2
      ;;
    t)
      title=$OPTARG
      echo "Title set as: $title" >&2
      ;;
    i)
      input="$OPTARG"
      echo "Input file(s) set as: $input" >&2
      ;;
    d)
      depth="$OPTARG"
      echo "Depth of looking for file(s) set as: $depth" >&2
      ;;
    h)
      usage $script
      echoblue $switches
      echo2 "Options: "\
              "        -i inputFOLDERS  Only matched folders will be plotted. For multiple paths use \"{path1,path2,...}*\""\
              "        -d DEPTH         As default the depth of looking for directory is 1."\
              "        -t TITLE         Title of the plot."\
              "        -s SKIP          Number of the electronic-steps to be skipped in total-energy plot."\
              "        -r               Skip the rms plot."\
              "        -h               Print this help" >&2
      echo ""
      exit 0
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage $script
      echoblue $switches
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage $script
      echoblue $switches
      exit 1
      ;;
  esac
done



rms=${rms:-"plot"}
SKIP=${SKIP:-'4'}
title=${title:-'---'}
echo $input
#input="${input:-.}"
echo $input

depth=${depth:-'1'}
here=`pwd`
echo -e "\n Current path: $here \n"
output='conv.dat'
outputRMS='convRMS.dat'
outputEP='convEP.dat'

#folders=`ls -1d "$pattern"*/`
#folders=`getFoldersContain $depth "OUTCAR*" "${input}"`
folders=`getFoldersContain "${input}" $depth "OUTCAR*"`
echo -e "Folders are:\n$folders \n"

for i in $folders;do
    cd $i
    CAR=`ls OUTCAR*`
    getTotalEneAllSteps $CAR | cat -n > tmp1
    getTotEneChangeAbs $CAR > tmp2
    getRMStotal $CAR | cat -n > $outputRMS
    if bzgrep -q E_p OSZICAR* || zgrep -q E_p OSZICAR*; then getE_pAll OSZICAR* | cat -n > $outputEP;fi
    paste tmp1 tmp2 > $output
    rm tmp1 tmp2 
    cd $here
done

#Ep=`for f in $folders; do if zgrep -q E_p $f/OSZICA*; then zgrep E_p $f/OSZICA* | tail -1 | awk '{print $NF}' ORS=' '; else echo 0; fi; done`
Ep=`for f in $folders; do if [ -s $f/$outputEP ]; then tail -1 $f/$outputEP | awk '{print $NF}' ORS=' '; else echo 0; fi; done`
echo $Ep

L=$LINES
C=$COLUMNS

#if [ $rms == "skip" ]; then
#echo '##SKIP'
#gnuplot -e "TIT='${title}'; folders='${folders}'; out='${output}'; outEP='${outputEP}'; COL='${C}'; LIN='${L}'; SKIP='${SKIP}'; EP='${Ep}'" /u/alizen/scripts/gnuprogressWOrms.plg
#else
#echo '##Plot'
#gnuplot -e "TIT='${title}'; folders='${folders}'; out='${output}'; outEP='${outputEP}'; COL='${C}'; LIN='${L}'; SKIP='${SKIP}'; EP='${Ep}'" /u/alizen/scripts/gnuprogress.plg
#fi
