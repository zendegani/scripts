#!/bin/bash

function crossProduct {
  declare -a v1=("${!1}")
  declare -a v2=("${!2}") 

#Note:  Can't pass by reference, so the global variable must be used
  vectResult[0]=$(( (v1[1] * v2[2]) - (v1[2] * v2[1]) ))
  vectResult[1]=$(( - ((v1[0] * v2[2]) - (v1[2] * v2[0])) ))
  vectResult[2]=$(( (v1[0] * v2[1]) - (v1[1] * v2[0]) ))

}

function normalize {
  declare -a v1=("${!1}") 

  fMag=`echo "scale=4; sqrt( (${v1[0]}^2) + (${v1[1]}^2) + (${v1[2]}^2) )" | bc -l`

  vectNormal[0]=`echo "scale=4;${v1[0]} / $fMag" | bc -l`
  vectNormal[1]=`echo "scale=4;${v1[1]} / $fMag" | bc -l`
  vectNormal[2]=`echo "scale=4;${v1[2]} / $fMag" | bc -l`

}

vect1[0]=3
vect1[1]=0
vect1[2]=0

vect2[0]=0
vect2[1]=4
vect2[2]=0

crossProduct vect1[@] vect2[@]
echo ${vectResult[0]} ${vectResult[1]} ${vectResult[2]}

normalize vectResult[@]
echo ${vectNormal[0]} ${vectNormal[1]} ${vectNormal[2]}

