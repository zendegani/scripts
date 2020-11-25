#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

result=`zgrep ".*" $pfad | awk '
    BEGIN{f1=0;f2=0;fullkp=0;highestValue=0;allkp=0;highOcc=0;lowOcc=10e5;nmd=0;nkp=0;n=0};  # f1=0(1): out of(in) k-point list, f2=0(1): out of(in) single k-point
    /irreducible/{irrkp=$2}; /NELECT/{elec=$3}; /NBANDS=/{nbands=$NF}; /energy  w/{n=n+1};   # irreducible k-points, nr of electrons, nr of bands, nr of all md steps
    /-----------/{f1=0};                                                                     # pattern signifies end of k-point list
    /potential at core/{f1=1;nmd=nmd+1;nkp=0};                                               # pattern signifies beginning of k-point list
    /band No/{if (f1==1) {f2=1;nkp=nkp+1;next}}                                              # pattern signifies start of a single k-point
    NF!=3&&f2==1{f2=0; allkp=allkp+1;                                                        # here we are at end of single k-point (NF!=3)
      if (highest<=lowOcc) { lowOcc=highest;  lowOccKP=nkp;  lowOccKP2=nmd};                 # if new highest is lower than all previous store nr of band/kp/MD step
      if (highest>=highOcc){highOcc=highest; highOccKP=nkp; highOccKP2=nmd};                 # if new highest is higher than all previous store nr of band/kp/MD step
      if (highest==nbands) {fullkp=fullkp+1; if(value^2>highestValue^2) highestValue=value}} # if completely full store occupation number if larger than all previous
    f1==1&&f2==1{if ($3!=0) {highest=$1; value=$3}}                                          #    square is needed because Methfessel-Paxton gives negative occupations
    END{print irrkp,elec,nbands,lowOcc,lowOccKP,lowOccKP2,highOcc,                           # both flags on so we collect nr of band and occupation if >0
              highOccKP,highOccKP2,fullkp,allkp,highestValue,nmd,n}'`
  
  # full path output or cutted formatted output with max 29 characters
  #if [ $pathInfo = True ]; then
  #  outcar=$i
  #else
  #  outcar=` echo $i | sed 's/.*\(.\{25\}\)$/... \1/' | awk '{printf("%-29s",$0)}'`
  #fi

  # put data from results variable into nice format
  irrkp=`  echo $result | awk '{printf("%6d",$1)}'`
  nelec=`  echo $result | awk '{printf("%7.2f",$2)}'`
  nbands=` echo $result | awk '{printf("%5d",$3)}'`
  lowOcc=`   echo $result | awk '{printf("%6d",$4)}'`
  lowOccKP=` echo $result | awk '{printf("%4d",$5)}'`
  lowOccKP2=`echo $result | awk '$1!=$11{printf("%4d",$6)}; $1==$11{print "    "}'`
  highOcc=`    echo $result | awk '{printf("%6d",$7)}'`
  highOccKP=`  echo $result | awk '{printf("%4d",$8)}'`
  highOccKP2=` echo $result | awk '$1!=$11{printf("%4d",$9)}; $1==$11{print "    "}'`
  fullkp=` echo $result | awk '{printf("%6d",$10)}'`
  allkp=`  echo $result | awk '{printf("%6d",$11)}'`
  highest=`echo $result | awk '{printf("%8.5f",$12)}'`
  nmd=`echo $result | awk '{printf("%4d",$13)}'`
  nmdall=`echo $result | awk '{printf("%4d",$14)}'`

echo "$highOcc" | sed 's| ||g' # $highOccKP $highOccKP2"
