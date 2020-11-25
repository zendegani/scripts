#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "OUTCAR dne: $pfad" && exit
#echo pfad: $pfad


structures=`echo $pfad | sed 's|OUTCAR.*|structures|'`
rm -f $structures
[ -e "$structures.gz" ] && rm -f $structures.gz

## pfad zu OUTCAR exists
## pfad zu OUTCAR exists
## pfad zu OUTCAR exists
## pfad zu OUTCAR exists
## pfad zu OUTCAR exists
## pfad zu OUTCAR exists


## anzahl der atome
## anzahl der atome
nions=`zgrep -a --text " number of ions     NIONS = " $pfad | awk '{print $12}'`
[ "$nions" = "" ] && echo OUTCAR seems to be corrupted && exit
nionsm1=` expr $nions - 1 `
  #echo N:$nions N-1:$nionsm1


## anzahl der gerechneten ionischen schritte, notwendig falls POSITIONS nicht geschrieben wurden
## anzahl der gerechneten ionischen schritte, notwendig falls POSITIONS nicht geschrieben wurden
anz_ene=`zgrep -a --text "free  en" $pfad | wc -l | sed 's|[ ]*||g'`



## letztendliche anzahl der Zeilen
## letztendliche anzahl der Zeilen
anz_zeilen=`echo "$anz_ene*$nions" | bc -l`
  #echo anz_zeilen:$anz_zeilen


 # zgrep -a --text ".*" $pfad | awk 'BEGIN{coff=0;ccor=0;offset=0;nions='$nionsm1';corLen=1;free=10000;enew=10000;enew0=10000};
 #        /free  en/{if(free==10000)ref=$5;free=$5};
 #        /energy  w/{if(enew==10000)refenew=$4;if(enew0==10000)refenew0=$7;enew=$4;enew0=$7};
 #        /POSITION /{coff++;if(coff>offset){ccor++;line=NR;if(ccor>corLen)ccor=0;next}};
 #        coff>0 && NR>line+1 && NR<=line+nions+1 {printf("%s %s %s %s %.6f %.6f %.6f %.6f %.6f %.6f %.2f %.2f %.2f\n",coff,$1,$2,$3,free,\
 #        enew,enew0,ref,refenew,refenew0,1000*(free-ref)/nions,1000*(enew-refenew)/nions,1000*(enew0-refenew0)/nions)}' > $structures




## coff>0 is necessary (sonst wird noch andres zeug geplottet
## line ist immer die Zeilennummer von POSITION
## NR>line+1 ist klar da 2 zeilen unter POSITION die strukturen losgehen
## NR<=line+nions+1 ist auch klar da bis dahin die POSITIONS geschrieben stehen :) in der OUTCAR


## funktionierend und kurz!
 # zgrep -a --text ".*" $pfad | awk 'BEGIN{coff=0;nions='$nionsm1';corLen=1;free=10000;enew=10000;enew0=10000};
 #        /free  en/{if(free==10000)ref=$5;free=$5};
 #        /energy  w/{if(enew==10000)refenew=$4;if(enew0==10000)refenew0=$7;enew=$4;enew0=$7};
 #        /POSITION /{coff++;{line=NR;next}};
 #        coff>0 && NR>line+1 && NR<=line+nions+1 {printf("%s %s %s %s %.6f %.6f %.6f %.6f %.6f %.6f %.2f %.2f %.2f\n",coff,$1,$2,$3,free,\
 #        enew,enew0,ref,refenew,refenew0,1000*(free-ref)/nions,1000*(enew-refenew)/nions,1000*(enew0-refenew0)/nions)}' > $structures

#echo yo2 :$nions:$nionsm1:$pfad
## auch eine version
zgrep -a --text ".*" $pfad | awk '{cell[NR]=$0};BEGIN{coff=0;nions='$nions';nionsm1='$nionsm1';corLen=1;free=10000;enew=10000;enew0=10000};
         /free  en/{if(free==10000)ref=$5;free=$5};
         /energy  w/{if(enew==10000)refenew=$4;if(enew0==10000)refenew0=$7;enew=$4;enew0=$7};
         /direct lattice vectors/{linecell=NR;};
         /POSITION /{coff++;{lineNrPOS=NR;next}};
         coff>0 && NR>lineNrPOS+1 && NR<=lineNrPOS+nions+1 {printf("%s %s %s %s %s %s %s %s %s\n",coff,$0,free,\
         enew,enew0,"||",cell[linecell+1],cell[linecell+2],cell[linecell+3])}' | \
         awk '{\
         printf "%-8s %-10.8f  %-10.9f %1.9f %-8s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s\n", \
         $1,$2,$3,$4,"|||recipcoord>","xxxxxxxxxx","xxxxxxxxxx","xxxxxxxxxx","|||forces>",$5,$6,$7,\
         "|||realcell>",$12,$13,$14,$18,$19,$20,$24,$25,$26,"||recipcell>",$15,$16,$17,$21,$22,$23,$27,$28,$29,"|||free>",$8,"|||ewe>",$9,"|||eS0>",$10}' > $structures

#echo yo3 :$anz_zeilen:
if [ "$anz_zeilen" != "`wc -l $structures | awk '{print $1}'`" ];then
    #echo you44
echo -e "\033[31m\033[1m some POSITIONS seem to be lost NIONS\033[0m PROBLEM :$nions anz_ene:$anz_ene NIONS*anz_ene:$anz_zeilen expected; counted lines:`wc -l $structures | awk '{print $1}'` `pwd`"
rm -f $structures
fi
#echo yo4
[ -e "$structures" ] && gzip $structures
