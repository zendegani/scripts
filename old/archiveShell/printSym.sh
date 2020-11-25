#!/bin/bash

if [ ! -d "Sym" ]; then
  mkdir Sym
fi

cd Sym
sxstructprint --vasp -i ../$1  > struct.sx
sxstructsym -i struct.sx > Sym.log
sxstructsym -i struct.sx --nonsymmorphic > SymNonSymmorphic.log

