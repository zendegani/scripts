#!/bin/bash
#get working directory
working_dir=`pwd`

## grundlegende Frage: soll die auswertung fuer einen FOLDER (./) oder fuer eine FILE (./OUTCAR.3.5.gz) erfolgen ???
##                -->  in einem bestimmten Folder sollen alle FILES ausgewertet werden

##                --> folderstruktur: {3.52Ang/OUTCAR,3.55Ang/OUTCAR}
##                --> OUTCAR_A.sh OUTCAR_numatoms.sh INCAR_ENCUT.sh  --> hier sind wirklich nur die OUTCAR Files
##                                                                       interessant wobei in dem entsprechenden
##                                                                       Folder die INCAR gefunden werden muss
##                --> 3.5Ang/OUTCAR 2 400
##                --> 3.6Ang/OUTCAR 2 400

##                --> folderstruktur: {OUTCAR.3.52.gz,OUTCAR.3.53.gz}
##                --> OUTCAR_A.sh OUTCAR_numatoms.sh INCAR_ENCUT.sh --> hier sind auch nur die OUTCAR Files interessant,
##                                                                      wobei die INCAR file (wenn existent) immer die gleich waere!
##                --> OUTCAR.3.52.gz 2 400
##                --> OUTCAR.3.53.gz 2 400

##   ---> FOLDER wird nur gebraucht wenn basename != OUTCAR (z.B. INCAR_ENCUT.sh) --> wenn es mehrere INCARS gibt wird das ausgegeben!

##   ---> 1. get all OUTCARS -> auswertung is done for all OUTCARS (folder wird nur 

#OUTCARS=`find -L . -type f -name "OUTCAR*"` # without sort -n seems to sort better
OUTCARS=`find -L . -maxdepth $1 -type f -name "OUTCAR*" | sort -n`  # sort -n is better in this case if ofther cases change to sort -t
#for var in `echo $*`;do
for var in "${@:2}"; do
    [ "$var" = "list" ] && list=yes && continue
    [ ! -e "`which $var 2> /dev/null`" ] && echo -e "\n\033[1;32m $var not found \033[0m" && exit
done
numvar=`echo $* | wc -w | sed 's|[ ]*||g' | sed 's|[ ]*||g'`
numvar=` expr $numvar + 1 `
# lenf decides how much space inbetween new column
lenf=22
#echo numv: $numvar
#exit
#echo OUTCARS:$OUTCARS:

#Formatting
list=no
la=0;for folder in $OUTCARS;do l=`echo $folder | wc -c | sed 's|[ ]*||g'`;[ "$l" -gt "$la" ] && la=$l; done  #la:max length $folder

for OUTCAR in $OUTCARS;do   ### OUTCAR loop
  OUTCARfolder=`echo $OUTCAR | sed 's|\(OUTCAR\).*||'`
  #echo OUTCAR: $OUTCAR OUTCARfolder:$OUTCARfolder
  out="$OUTCAR"                 ## 2 400 , first set to filename  -> out: 3.52/OUTCAR 2 400
  outlist=""                    ## when list is requested         -> out: 2 400
  outb=`echo pfad`              ## outb ist die beschriftung (last line) -> pfad volumelastperatom ene-lastperatom 

  for var in `echo $*`;do  ## var ist z.B. OUTCAR_number_of_atoms.sh oder OUTCAR_memGB.sh oder INCAR_ENCUT.sh
    [ "$var" = "list" ] && list=yes && continue
    basename=`echo $var | sed 's|_.*||'`   ## basename ist OUTCAR INCAR KPOINTS POSCAR POTCAR
    file_to_check=$OUTCAR
    #echo OUTCAR:$OUTCAR OUTCARfolder:$OUTCARfolder var:$var basename:$basename file_to_check:$file_to_check   
    [ "$basename" != "OUTCAR" ] && file_to_check=`find -L $OUTCARfolder -type f -name "$basename*"`
    
    ## get values (add)    
    [ ! -e "$file_to_check" ] && add=dne && continue
    #echo OUTCAR:$OUTCAR OUTCARfolder:$OUTCARfolder var:$var basename:$basename file_to_check:$file_to_check     
    [ "`echo $file_to_check | wc -w | sed 's|[ ]*||g' | sed 's|[ ]*||g'`" != "1" ] && add=not_one_$basename && continue

    [ "$var" != "" ] && [ "$var" != "list" ] && add=`$var $file_to_check` && addb=`echo $var | sed 's|.*_||' | sed 's|\.sh||'`
    #echo add:$add:
    out=`echo -e "$out" " \t $add" | sed 's|^-e ||'`
    outlist=`echo -e "$outlist" " \t $add"`
    outb=`echo -e "$outb " " \t $addb"`
    #echo out:$out:
  done  ## variable loop

  ### WRITE TO SCREEN
  ### WRITE TO SCREEN
  [ "$list" = "yes" ] && echo -e "$outlist" | sed 's|^-e ||' | awk '{for(i=1;i<='"$numvar"';i++) printf("%'"$lenf"'s",$i); printf("\n")}' && continue 
  echo -e "$out" | sed 's|^-e ||' | awk '{printf("%'"$la"'s",$1); for(i=2;i<='"$numvar"';i++) printf("%'"$lenf"'s",$i," "); printf("\n")}'
done ## OUTCAR loop

### BESCHRIFTUNG
### BESCHRIFTUNG
[ "$list" != "yes" ] && echo -e "$outb" | sed 's|^-e||' | awk '{printf("%'"$la"'s",$1); for(i=2;i<='"$numvar"';i++) printf("%'"$lenf"'s",$i); printf("\n")}'
#/bin/bash -c "echo -e '\E['31';'01'm pfad hallo';tput sgr0"

