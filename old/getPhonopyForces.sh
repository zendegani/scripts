#!/bin/bash

gunzip */vasprun.xml.gz
echo
bunzip2 */vasprun.xml.bz2
list=`ls -1d disp-*`
echo $list
allxml=`for i in $list; do printf $i"/vasprun.xml ";done`
phonopy -f $allxml
bzip2 */vasprun.xml
