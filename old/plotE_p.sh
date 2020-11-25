#!/bin/bash
#ver 2015.11.18

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

switches="[-i inputFOLDERS] [-d DEPTH] [-t TITLE] [-h] "
while getopts "d:s:t:i:h" opt; do
  case $opt in
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

SKIP=${SKIP:-'4'}
title=${title:-'---'}
input="${input:-.}"
depth=${depth:-'1'}
output='results.dat'
folders=`getFoldersContain "${input}" $depth "OUTCAR*"`
echogreen "Folders are:\n$folders \n"

here=`pwd`
echo -e "\n Current path: $here \n"

touch $output
echored "E0            E_p         LAMBDA"
#     -428.98979244 0.10588E+01 0.100E+01

for i in $folders;do
    cd $i
    OUTCAR_forces-last-ARRAY.sh > forces-last-ARRAY.dat
    OUTCAR=`ls OUTCAR*`
    OSZICAR=`ls OSZICAR*`
    E0=`getE0LastStep $OUTCAR`
    if [ -z $E0 ]; then E0=`getE0AllSteps $OUTCAR | tail -1`; fi
    E_p=`getE_pLast $OSZICAR`
    LAMBDA=`getLAMBDA $OSZICAR`
    echo $E0 $E_p $LAMBDA
    cd $here
    echo $E0 $E_p $LAMBDA >> $output
done
echo
#find folder with max LAMBDA to take as a reference for force ...
folerLine=`awk  'BEGIN{max=0}{if(($3)>max)  {max=($3); lineNo=NR}}END {print lineNo}' $output`
folderName=`echo "$folders" | head -$folerLine | tail -1`
echo "Max LAMBDA line#" $folerLine $folderName
python /u/alizen/scripts/calculateMatrixDifferences.py $folderName $folders
echo '##Plot'
gnuplot -e "TIT='${title}'; outEP='${output}'" /u/alizen/scripts/gnuEp.plg
paste $output Forces.dat > LAMBDAvsFORCES.dat
rm $output Forces.dat
