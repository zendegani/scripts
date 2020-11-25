#!/bin/sh

#[ ! -e "$1/OUTCAR" ] && OUTCAR dne
debug=noyes
[ "$debug" = "yes" ] && echo XXXCAR_link-to-basename.sh $0 $1
pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit
[ "$debug" = "yes" ] && echo ------------------------------------------------------------------------pafd: $pfad

#iteration=`tail -100 $pfad | grep --mmap -a --text Iteration | tail -1` # | sed 's|-||g' | sed 's|Iteration||' | sed 's| ||g' | xargs -n1 | tail -1`
#iteration=`grep --mmap -a --text Iteration $pfad | tail -1` # | sed 's|-||g' | sed 's|Iteration||' | sed 's| ||g' | xargs -n1 | tail -1`
#iteration=`sed -n 's|Iteration\(.*\)|\1|p' $pfad | tail -1 | sed 's|-||g' | sed 's|^[ ]*||g'`
[ "$debug" = "yes" ] && echo it111: wait
iteration=`tail -400 $pfad | sed -n 's|Iteration\(.*\)|\1|p' | tail -1 | sed 's|-||g' | sed 's|^[ ]*||g'`
[ "$debug" = "yes" ] && echo it111:$iteration
[ "$iteration" = "" ] && iteration=`zgrep Iteration $pfad | tail -1 | sed 's|-||g' | sed 's|Iteration||' | sed 's| ||g' | xargs -n1 | tail -1`
[ "$iteration" = "" ] && iteration='---'
echo $iteration
