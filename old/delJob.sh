#!/bin/bash

qstat | grep alizen | awk '{print $1}' > jobs.tmp
while read LINE <&9; do
echo " Remove $LINE ?"
read -n 1 input
if [[ $input == "y" ]]; then
    echo  $LINE will ....
    qdel $LINE
fi  
done 9<jobs.tmp

rm jobs.tmp

