#!/bin/bash
#ver 2015-11-12

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

while getopts "d:w:n:h" opt; do
  case $opt in
    d)
      magDirec=$OPTARG
      echo "Checking $magDirec direction..." >&2
      ;;
    w)
      binWidth=$OPTARG
      echo "Width of bins set to $binWidth" >&2
      ;;
    n)
      natoms=$OPTARG
      echo "Number of atoms are $natoms" >&2
      ;;
    h)
     echo ""
      echo -n -e "\033[31m\033[1mUSAGE\033[0m:   \033[1m$name  \033[0m\n"
      echo""
      echo -e "Options: -d DIRECTION              Specifies the magnetic moments direction to check. \n"\
              "        -n WyckoffMultiplicity    List them in quotation e.g. \"2 6 4\" \n"\
              "        -h                        Print this help\n" >&2
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

magDirec=${magDirec:-'z'}
echo "Spins direction is $magDirec"
binWidth=${binWidth:-0.1}
OUTCAR=`ls OUTCAR*`
magOUT='Magmoms.dat'
echo "Check number of atoms ... "
numatoms=`getAtomsNr $OUTCAR`
echo "done!"
natoms=${natoms:-$numatoms}
magLineNum=`echo 3+$numatoms | bc`
echo "Check magnetization table ... "
result=`zgrep ".*" $OUTCAR  | tail -r | grep 'magnetization ('$magDirec')' -B$magLineNum -m1 | tail -r`
#result=`zgrep ".*" $OUTCAR  | tac | grep 'magnetization ('$magDirec')' -B$magLineNum -m1 | tac`
echo  "$result" | tail -$numatoms | awk '{print $1 " " $NF}' > $magOUT
echo "done!"

#gnuplot -e "BinWidth='${binWidth}';FILE='${magOUT}'" /u/alizen/scripts/gnuhistmag.plg
#header=`which python`
#echo $header
#sed -i .bak "1s|.*|#!$header|" /u/alizen/scripts/plotmag.py
echo "Calling python script"
python /u/alizen/scripts/plotmag.py $magOUT "$natoms"

