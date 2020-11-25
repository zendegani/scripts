#!/bin/sh


pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

forces=`OUTCAR_forces-last-ARRAY.sh $pfad`  # has still all the digits
echo "$forces" | xargs -n1 | awk '{printf "%.6f\n", sqrt($1^2)}' | awk 'max==""|| $1>max {max=$1}END{ print max}'
#awk 'NR == 1 {max=$2 ; min=$2} $2 >= max {max = $2} $2 <= min {min = $2} END { print "Min: "min,"Max: "max }' 
# number_atoms=`OUTCAR_number_of_atoms.sh $pfad` #   filename`
# einmehr=` expr $number_atoms + 1 `
# n=` expr $number_atoms + 2 `
# 
# # check if input file is compressed
# # get all POSITIONs from OUTCAR; we also write just the flag POSITION into _tmp_
# # in order to count the nr of steps from this
# zip=`file $pfad | sed 's/.*gzip compressed data.*/True/'`
# rm -f _tmp_
# #echo zip:$zip
# #echo n:$n:
# if [ "$zip" = True ];then
#     #fre=`zgrep "free energy" $pfad`
#     #tmp=`zgrep ".*" $pfad`
#     #echo pfad:$pfad
#     #echo zip:$zip
#     #echo in    
#     #echo n:$n:
#     #echo einmehr:$einmehr:
#     tmp=`zgrep -A$einmehr POSITION $pfad | sed 's|POSITION.*||' | sed 's|.*--.*||g' | sed '/^ *$/d'`
#     
#     #zgrep "TOTAL-FORCE (eV/Angst)" OUTCAR -A 1000 | grep "total drift:" -B 1000 | sed '/total/d' | sed '/POSITION/d' | sed '/---------/d' | awk '{print $4"\t", $5"\t", $6}'
#     #sed -n -e '/^ POSITION/,+'$n'{s/[0-9]\+/\0/p}' -e '/^ POSITION/w _tmp_' $file  > _tmp_POSITIONs
# 
# else
#     #fre=`sed -n '/free energy/p' $pfad`
#     #echo n:$n
#     #tmp=`sed -n -e '/^ POSITION/,+'"$n"'{s/[0-9]\+/\0/p}' $pfad`
#     tmp=`grep -A$einmehr POSITION $pfad | sed 's|POSITION.*||' | sed 's|.*--.*||g' | sed '/^ *$/d'`
# fi
# echo tmp:$tmp
# tmp=`echo $tmp | tail -$number_atoms`
# lines=`echo "$tmp" | wc -l | sed 's|[ ]*||g'`
# modulo=` expr $lines % $number_atoms`
# iterations=` expr $lines / $number_atoms `
# seq=`awk 'BEGIN {x=0; while(++x<='"$iterations"'){print x; }; exit}'`
# linebegin=1;lineend=0
# #echo lines:$lines
# #echo modulo:$modulo
# #echo iterations:$iterations
# #echo seq:$seq
# 
# for i in $seq;do
#     lineend=` expr $linebegin + $number_atoms - 1 `
#     #echo i:$i linebegin:$linebegin lineend:$lineend
#     pos=`echo "$tmp" | sed -n ''"$linebegin"','"$lineend"'p' | awk '{print $4,$5,$6}' | sed 's|-||g' |  awk '{max=0;for (i=1; i<=NF;i=i+1){if($i>max){max=$i}};print max}' | awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print max}'`
# 
#     echo "$pos" 
#     linebegin=` expr $lineend + 1 `
# done
