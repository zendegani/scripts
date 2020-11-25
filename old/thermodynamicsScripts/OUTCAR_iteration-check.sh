#!/bin/sh

## This script checks if some iterations are missing inbetween and stops the job if this is the case
out=no #yes #(print additional info for debugging when yes)
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`;[ "$out" = "yes" ] && echo path: $path
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`;[ "$out" = "yes" ] && echo script: $script
options=$*; . $path/../utilities/functions.include; checkOptions "-h -help -v";[ "$out" = "yes" ] && echo options: $options

pfad=`XXXCAR_link-to-basename.sh $0 $1`
#echo pfad:$pfad 0:$0 1:$1
[ ! -e "$pfad" ] && echo "dne $pfad to OUTCAR" && exit

    maxiter=`OUTCAR_iteration-max.sh $pfad | sed 's|(.*||'`
    isnumber1=`isnumber.sh $maxiter`
    [ "$isnumber1" != "yes" ] && echo prob1 && exit
    #[ "`checkInteger $isnumber1`" != "ok" ] && echo prob1n && exit
    itermissing=`OUTCAR_iteration-missing.sh $pfad`
    isnumber2=`isnumber.sh $itermissing`
    
    [ "$isnumber2" != "yes" ] && echo prob2 && exit

    #[ "`checkInteger $isnumber2`" != "ok" ] && echo prob2 && exit
    iterdiff=` expr $maxiter - $itermissing `

    #echo ""
    #echo maxiter $maxiter
    #echo isnumber1 $isnumber1
    #echo itermissing $itermissing
    #echo isnumber2 $isnumber2
    #echo iterdiff $iterdiff
    [ "`checkReal $iterdiff`" != "ok" ] && error "iterdiff:$iterdiff: is no number prob3 :maxiter:$maxiter: isnumber1:$isnumber1: itermissing:$itermissing:isnumber2:$isnumber2"
    [ "$iterdiff" -ge "4" ] && echo "iterdiff $iterdiff -> going to kill job" && qdel.sh `OUTCAR_ID.sh $pfad`
    echo OK

