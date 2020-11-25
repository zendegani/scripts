#!/bin/bash
#ver 2015-11-16

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

while getopts "i:h" opt; do
  case $opt in
    i)
      input=$OPTARG
      echo "q-path will read from $input" >&2
      ;;
    h)
     echo ""
      echo -n -e "\033[31m\033[1mUSAGE\033[0m:   \033[1m$name  \033[0m\n"
      echo""
      echo -e "Options: -i INPUT    Specifies the file contains q-path; Default 'phononSet.sx' . \n"\
              "        -h          Print this help\n" >&2
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      echo -n -e "Use \033[1m$name \033[0m -h  to see help\n" >&2
      exit 1
      ;;
  esac
done

input=${input:-'phononSet.sx'}
if [ ! -e $input ]; then
  echored "Error: File '$input' does not exist!"
  exit 1
fi

file_phonon='phonon.out'
file_npoints='npoints.dat'
file_lables='labels.dat'
file_path='qpath.dat'

grep coords $input | sed 's/.*label.*="\(.\).*/\1/' > $file_lables
echo "0" > $file_npoints
grep -i nPoints $input | sed 's/.*nPoints.*=\s*\([0-9]*\).*/\1/' >> $file_npoints
grep coords $input | sed 's/.*\[\(.*\)\].*/\1/' | sed 's/,/ /g' > $file_path


echo "Calling python script"
python /u/alizen/scripts/plotDispersion.py $file_phonon $file_npoints $file_lables $file_path

