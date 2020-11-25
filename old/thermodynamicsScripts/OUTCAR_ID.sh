#!/bin/sh
allarg=$*
[ "$allarg" = "" ] && allarg=.
for argument in $allarg;do
    #echo $argument
    pfad=`XXXCAR_link-to-basename.sh $0 $argument`
    #echo argument:$argument pfad:$pfad
    #continue
    out=""
    if [ ! -e "$pfad" ];then
        tmpjobid=`find -L $argument -maxdepth 1 -mindepth 1 -name "jobID_*" | sed 's|.*jobID_||g'`
        #echo mpt $tmpjobid
        [ "`isnumber.sh $tmpjobid`" = "yes" ] && echo $tmpjobid && continue
        echo "XXCAR error: $pfad" && exit
    fi
    
    pfadneu=`echo $pfad | sed 's|OUTCAR.*||'`; [ "$pfadneu" = "" ] && pfadneu=.
    #echo pfad:$pfad pfadneu:$pfadneu
    
    out=`find $pfadneu -maxdepth 1 -mindepth 1 -type f -name "*.po[1-9]*" | sed 's|.*po||' | sort | tail -1`
    if [ "$out" = "" ]; then 
        out=`ls -1d jobID_* | sed 's|jobID_||'` 
    fi
    [ "$out" = "" ] && out=--- 
    echo $out
    done
