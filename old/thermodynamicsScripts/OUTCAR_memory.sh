#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit


## This script needs to be adapted
## Liang: Take for the kB mem the memory times the amount of irreducible kpoints .... this did not work out .... retry

kB=`zgrep -a --text "total amount of memory used by VASP on root node" $pfad | tail -1 | sed 's| total amount of memory used by VASP on root node||' | sed 's|. kBytes||'`
[ "$kB" != "" ] && mem=`echo "$kB/1048576" | bc -l  | sed 's|\([0-9]*\).\([0-9][0-9]\).*|\1.\2|'` && echo $mem && exit



mem=`zgrep "Maximum memory used (kb):" $pfad | awk '{printf "%.3f", $5/1000000}'`
[ "$mem" = "" ] && mem=---- 
echo $mem


