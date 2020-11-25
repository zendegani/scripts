#!/bin/bash
t1=$(date -u -d "`OUTCAR_time-started.sh | sed 's|\.|/|g' | sed 's/_/ /'`" +"%s")
t2=$(date -u -d "`OUTCAR_time-lastwrite.sh| sed 's|\.|/|g' | sed 's/_/ /'`" +"%s")
secs=`echo $(( t2 - t1 ))`
printf '%dh:%dm:%ds\n' $(($secs/3600)) $(($secs%3600/60)) $(($secs%60))
