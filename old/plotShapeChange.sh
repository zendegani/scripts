#!/bin/bash

zgrep ".*" OUTCAR* | awk '/length of vectors/{getline; print}'  | cat -n > plot.dat
gnuplot -e "set ytics nomirror; set y2tics; plot 'plot.dat' using 1:2 w l axes x1y1, '' u 1:4 w l axes x2y2"
