#!/bin/bash

rm DOSCAR EIGENVAL PROCAR PCDAT IBZKPT 
bzip2 POTCAR 2>/dev/null
bzip2  std.log
bzip2 -f vasprun.xml OSZICAR
gzip -f OUTCAR

