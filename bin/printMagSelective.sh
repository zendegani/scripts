#!/bin/bash

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`

options=$*; . $path/azfunctions.include;

switches="[-i inputFOLDERS] [-d DEPTH] [-m AXIS] [-h] [-p] [-r string of moment] [-s FILEtoSAVE] [-z] [-c ignore last n moments]"
while getopts "d:m:i:r:s:c:hpz" opt; do
  case $opt in
    p)
      printTable="TRUE"
      echo "Magnetization tables will be printed out." >&2
      ;;
    s)
      saveTable="TRUE"
      FILEtoSAVE="$OPTARG"
      echo "Magnetization tables will be save in $FILEtoSAVE." >&2
      ;;
    m)
      magDirec="$OPTARG"
      echo "magnetization ($magDirec)" >&2
      ;;
    r)
      magMOMS="$OPTARG"
      echo "Magnetic moments will be compared with ($magMOMS) instead of reading from INCAR" >&2
      ;;
    z)
      ignoreZero="TRUE"
      echo "Zero initialised magnetic moments will be ignored in comparison" >&2
      ;;
    i)
      input="$OPTARG"
      echo "Input file(s) set as: $input" >&2
      ;;
    d)
      depth="$OPTARG"
      echo "Depth of looking for file(s) set as: $depth" >&2
      ;;
    c)
      cutlast="$OPTARG"
      echo "Ignore the last n moment(s): $cutlast" >&2
      ;;
    h)
      usage $script
      echo "$switches"
      echo2 "Options: "\
              "        -i inputFOLDERS  Only matched folders will be plotted. For multiple paths use \"{path1,path2,...}*\""\
              "        -d DEPTH         As default the depth of looking for directory is 1."\
              "        -m AXIS          Extract the data of x,y or z direction of magnetic moments out of OUTCAR."\
              "        -c n             Ignore flipping in the moments of the last n atoms."\
              "        -p               Printing the magnetization table(s)."\
              "        -s outputFILE    Saving the magnetization table(s) e.g. in moments.dat."\
              "        -r newMAGMOM     Override the source of comparison, which is magnetic moments in the INCAR."\
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


#FILEtoSAVE=${FILEtoSAVE:-'moments.dat'}
ignoreZero=${ignoreZero:-'FALSE'}
printTable=${printTable:-'FALSE'}
saveTable=${saveTable:-'FALSE'}
magDirec=${magDirec:-'z'}
input="${input:-"./"}"
depth=${depth:-'1'}
cutlast=${cutlast:-'0'}
echo "###Initialised: ","$printTable", "$magDirec", "$input", "$depth"
folders=`getFoldersContain "${input}" $depth "OUTCAR*"`
#folders=`getFoldersContain $depth "OUTCAR*" "${input}"`
echo -e "Folders are:\n$folders \n"
OUTCAR=OUTCAR
here=`pwd`
c=0
stayed=0
flipped=0
for i in $folders;do
    let c++
    echo "###################################### $i"
    cd $i
    result[$c]=`printMagnetizationTable $magDirec $OUTCAR`
    if [ $saveTable == 'TRUE' ]; then
        printMagnetizationTableNoHeader $magDirec $OUTCAR > $FILEtoSAVE;
    fi

    if [ $printTable == 'TRUE' ]; then
        echo "${result[$c]}";
        echo "################################# $i"
    fi
    echo "${result[$c]}" | parseMagnetizationTable2 > tmpOUT
    [ ! -z "$magMOMS" ] && printf "$magMOMS" > tmpINC || parseINCARmag INCAR $magDirec > tmpINC
    compareTwoStringCbyC tmpINC tmpOUT
    if [ $ignoreZero == 'TRUE' ]; then
            compareTwoStringCbyC_adaptZeros tmpINC tmpOUT
    fi
    diff <(sed 's/.\{'$cutlast'\}$//' tmpOUT) <(sed 's/.\{'$cutlast'\}$//' tmpINC)  > /dev/null 2>&1
    if [ $? -eq 0 ] ; then
            echogreen "Spins are in the same directions as initialised" ;
            let stayed++
        else
            echored   "WARNING: Spins are flipped!"
            let flipped++
    fi
    zgrep E_p OSZICAR* | tail -1
    grep -i I_CONSTRAINED_M INCAR
    rm tmpOUT tmpINC
    cd $here
done

echoblue "################################"
echogreen "$stayed ok" ;
echored   "$flipped flipped";
echoblue "################################"






















