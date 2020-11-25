#!/bin/sh


pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

number_atoms=`OUTCAR_number_of_atoms.sh $pfad` #   filename`
einmehr=` expr $number_atoms + 1 `
n=` expr $number_atoms + 2 `

# check if input file is compressed
# get all POSITIONs from OUTCAR; we also write just the flag POSITION into _tmp_
# in order to count the nr of steps from this
zip=`file $pfad | sed 's/.*gzip compressed data.*/True/'`
rm -f _tmp_
isgz="${pfad: -3}"
if [ "$isgz" = ".gz" ];then
    zip=True
fi
#echo zip:$zip
#echo zip:$zip
#echo n:$n:
if [ "$zip" = True ];then
    #fre=`zgrep "free energy" $pfad`
    #tmp=`zgrep ".*" $pfad`
    #echo pfad:$pfad
    #echo zip:$zip
    #echo in    
    #echo n:$n:
    #echo einmehr:$einmehr:
    tmp=`zgrep -A$einmehr POSITION $pfad | sed 's|POSITION.*||' | sed 's|.*--.*||g' | sed '/^ *$/d'`
    
    #zgrep "TOTAL-FORCE (eV/Angst)" OUTCAR -A 1000 | grep "total drift:" -B 1000 | sed '/total/d' | sed '/POSITION/d' | sed '/---------/d' | awk '{print $4"\t", $5"\t", $6}'
    #sed -n -e '/^ POSITION/,+'$n'{s/[0-9]\+/\0/p}' -e '/^ POSITION/w _tmp_' $file  > _tmp_POSITIONs

else
    #fre=`sed -n '/free energy/p' $pfad`
    #echo n:$n
    #tmp=`sed -n -e '/^ POSITION/,+'"$n"'{s/[0-9]\+/\0/p}' $pfad`

    tmp=`grep -A$einmehr POSITION $pfad | sed 's|POSITION.*||' | sed 's|.*--.*||g' | sed '/^ *$/d'`
fi

lines=`echo "$tmp" | wc -l | sed 's|[ ]*||g'`
modulo=` expr $lines % $number_atoms`
#echo lines:$lines
#echo modulo:$modulo
[ "$modulo" != "0" ] && echo got lines:$lines: and atoms:$atoms: thus problem because some lines missing && exit
echo "$tmp" | awk '{print $1,$2,$3}' | tail -$number_atoms

#echo number_atoms:$number_atoms
#echo einmehr:$einmehr
#echo pfad:$pfad
#zgrep "TOTAL-FORCE (eV/Angst)" OUTCAR -A 1000 | grep "total drift:" -B 1000 | sed '/total/d' | sed '/POSITION/d' | sed '/---------/d' | awk '{print $4"\t", $5"\t", $6}'

#zgrep -A $einmehr "TOTAL-FORCE (eV/Angst)" $pfad
