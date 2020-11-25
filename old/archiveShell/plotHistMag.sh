#!/bin/bash

#ver 2015.10.26

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
echo Spins direction $magDirec
binWidth=${binWidth:-0.1}
OUTCAR=`ls OUTCAR*`
magOUT='Magmoms.dat'
numatoms=`zgrep -a --text "number of ions     NIONS = " $OUTCAR | awk '{print $12}'`
natoms=${natoms:-$numatoms}
magLineNum=`echo 3+$numatoms | bc`
result=`zgrep ".*" $OUTCAR  | tail -r | grep 'magnetization ('$magDirec')' -B$magLineNum -m1 | tail -r`
echo  "$result" | tail -$numatoms | awk '{print $1 " " $NF}' > $magOUT

#gnuplot -e "BinWidth='${binWidth}';FILE='${magOUT}'" /u/alizen/scripts/gnuhistmag.plg
#header=`which python`
#echo $header
#sed -i .bak "1s|.*|#!$header|" /u/alizen/scripts/plotmag.py
python /u/alizen/scripts/plotmag.py $magOUT "$natoms"

