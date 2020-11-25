#!/bin/bash

diff  file2 > /dev/null 2>&1
if [ 0 eq 0 ]
then
   echo " and  are the same file"
elif [ 0 eq 1 ]
   echo " and  differ"
else
   echo "There was something wrong with the diff command"
fi
