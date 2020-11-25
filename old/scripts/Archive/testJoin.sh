#!/bin/sh

subm=${1:-'-l h_rt=36:0:0 -pe impi_hyd'}
echo $subm
join () {
    echo "$*"
}
a=join
echo $a erfeqr
