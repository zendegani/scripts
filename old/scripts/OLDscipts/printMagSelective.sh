#!/bin/bash

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

switches="[-i inputFOLDERS] [-d DEPTH] [-m AXIS] [-h] [-p]"
while getopts "d:m:i:hp" opt; do
  case $opt in
    p)
      printTable="TRUE"
      echo "Magnetization tables will be printed out." >&2
      ;;
    m)
      magDirec=$OPTARG
      echo "magnetization ($magDirec)" >&2
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
      echo "$switches"
      echo2 "Options: "\
              "        -i inputFOLDERS  Only matched folders will be plotted. For multiple paths use \"{path1,path2,...}*\""\
              "        -d DEPTH         As default the depth of looking for directory is 1."\
              "        -m AXIS          Extract the data of x,y or z direction of magnetic moments out of OUTCAR."\
              "        -p               Printing the magnetization table(s)."\
              "        -h               Print this help" >&2
      echo ""
      exit 0
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage $script
      echo "$switches"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage $script
      echo "$switches"
      exit 1
      ;;
  esac
done

printTable=${printTable:-'FALSE'}
magDirec=${magDirec:-'z'}
input="${input:-"./"}"
depth=${depth:-'1'}
echo "###Initialised: ","$printTable", "$magDirec", "$input", "$depth"
folders=`getFoldersContain "${input}" $depth "OUTCAR*"`
echo -e "Folders are:\n$folders \n"
OUTCAR=OUTCAR
here=`pwd`
c=0
for i in $folders;do
    let c++
    cd $i
    result[$c]=`printMagnetizationTable $magDirec $OUTCAR`
    if [ $printTable == 'TRUE' ]; then
        echo "############### $i ##################"
        echo "${result[$c]}";
    fi
    echo "${result[$c]}" | parseMagnetizationTable2 > tmpOUT
    parseINCARmag INCAR > tmpINC
    cd $here
done

echo
echo "Spins along $magDirec axis ..."

cd $here
c=0
for i in $folders;do
    let c++
    cd $i
    echo "############### $i ##################"
    compareTwoStringCbyC tmpINC tmpOUT
    diff tmpOUT tmpINC  > /dev/null 2>&1
    if [ $? -eq 0 ] ;
        then  echogreen "Spins are in the same directions as initialised" ;
        else  echored   "WARNING: Spins are flipped!"
    fi
    zgrep E_p OSZICAR | tail -1
    grep -i I_CONSTRAINED_M INCAR
    rm tmpOUT tmpINC
    cd $here
done
