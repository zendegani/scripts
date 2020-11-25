#!/bin/bash

L=$LINES
C=$COLUMNS
gnuplot -e "COL='${C}'; LIN='${L}'" $HOME/scripts/gnumurn.plg


