#!/bin/bash

js=`qstat | grep $USER | awk '{print $1}'`
for i in $js ;do
 f=`qstat -j $i | grep sge_o_workdir | awk '{print $2}'`
 s=`qstat | grep $USER | grep $i | awk '{print $5 " " $NF}'`
 echo $i $s $f
done
