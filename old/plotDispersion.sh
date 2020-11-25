#!/bin/bash
#ver 2015-11-22

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

switches="[-i INPUT] [-t TITLE] [-h] "
while getopts "i:t:h" opt; do
  case $opt in
    i)
      input=$OPTARG
      echo "q-path will read from $input" >&2
      ;;
    t)
      title=$OPTARG
      echo "Title set as: $title" >&2
      ;;
    h)
      usage $script
      echoblue $switches
      echo2 "Options: "\
              "        -i   INPUT    Specifies the file contains q-path; Default 'phononSet.sx'."\
              "        -t   TITLE    Title of the plot."\
              "        -h            Print this help" >&2
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

input=${input:-'phononSet.sx'}
if [ ! -e $input ]; then
  echored "Error: File '$input' does not exist!"
  exit 1
fi

title=${title:-'---'}

file_phonon='phonon.out'
file_npoints='npoints.dat'
file_lables='labels.dat'
file_path='qpath.dat'

grep coords $input | sed 's/.*label.*="\(.\).*/\1/' > $file_lables
echo "0" > $file_npoints
grep -i nPoints $input | sed 's/.*nPoints.*=\s*\([0-9]*\).*/\1/' >> $file_npoints
grep coords $input | sed 's/.*\[\(.*\)\].*/\1/' | sed 's/,/ /g' > $file_path


echo "Calling python script"
python /u/alizen/scripts/plotDispersion.py $file_phonon $file_npoints $file_lables $file_path $title

