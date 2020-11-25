#!/bin/sh

## dne: file does not exist

## yes: finished and ok
## yCD: finished but problems with charge density consistency
## ybF: finished but gives not last FORCES and not last POSITIONS

## no : not finished
## nCD: not finished and problems with charge density consistency

pfad=`XXXCAR_link-to-basename.sh $0 $1`

#echo pfad:$pfadXXXCAR_link-to-basename.sh
#exit
#echo pfad: $pfad try: XXXCAR_link-to-basename.sh $0 $1
[ ! -e "$pfad" ] && echo "dne" && exit


calcdone=`zgrep -a --text -s "Total CPU time used " $pfad | tail -1 | wc -l | sed 's|[ ]*||g' | sed 's|[ ]*||g'` 
calcdoneHFc=`zgrep -a --text -s "^HF-correction " $pfad | tail -1 | wc -l | sed 's|[ ]*||g' | sed 's|[ ]*||g'` 
[ "$calcdone" = "1" -o "$calcdoneHFc" = "1" ] && calcdone=yes
[ "$calcdone" != "yes" ] && calcdone=no

###############################################
#	check if dUdL file exists if calconde=no	
###############################################
#dUdL=""
#echo calcdone:$calcdone
#if [ "$calcdone" != "yes" ];then
  dUdL=`echo $pfad | sed 's|OUTCAR.*|dUdL|'`
  #echo dUdL:$dUdL
  dUdLok=yes
  #[ -e $dUdL ] && dUdLok=ok
  [ -e $dUdL ] && [ "`zgrep "NaN" $dUdL | wc -l | sed 's|[ ]*||g' | sed 's|[ ]*||g'`" -gt "0" ] && dUdLok=NaN
  #echo dUdLok:$dUdLok
#fi


###############################################
#		check charge density differences
###############################################
ele=`zgrep ".*" $pfad | grep "number of electron" | awk '{print $4}' | sort | uniq | sed 's|total||' | sed '/^$/d'`
charge=`echo "$ele" | sed -n '$='`
chargeok=no; [ "$charge" = "" ] && chargeok=yes ; [ "$charge" = "1" ] && chargeok=yes
#echo ele:$ele
#echo charge:$charge 
#echo chargeok:$chargeok


if [ "$chargeok" != "yes" ];then
			#echo in1
			if [ "`echo "$ele" | sed -n 's|.*\(\*\*\*\).*|\1|p' | wc -w | sed 's|[ ]*||g' | sed 's|[ ]*||g'`" = "0" ];then
				#echo in2
				max=`max.sh $ele`
				min=`min.sh $ele`
				dif=`echo $max $min | awk '{print $1-$2}'`
			#	echo max:$max min:$min dif:$dif
		        #		echo "$dif < 0.0001"
			#	echo "$dif < 0.0001" | bc 

			eleok=`echo $dif 0.0001 | awk '($1<=$2){print "yes"};($1>$2){print "no"}'`
                #echo eleok: $eleok        
		#		[ $(echo "$dif < 0.0001" | bc) -eq "1" ] && eleok=yes
		#	else
		#		eleok=no
			fi
fi
#echo ele:$ele
#echo charge:$charge 
#echo chargeok:$chargeok
#echo eleok:$eleok -- only relevant if chargeok is not yes
#[ -e $dUdL ] && echo exists:dUdL:$dUdL
#[ ! -e $dUdL ] && echo does not exist:dUdL
#echo dUdLok:$dUdLok
#echo ""

###################################################################################
#	check if OUTCAR is finished but no output of last FORCES and POSITIONS	
###################################################################################
[ "$calcdone" = "no"  ] && [ "`zgrep -a --text "aborting loop because EDIFF is reached" $pfad | wc -w | sed 's|[ ]*||g' | sed 's|[ ]*||g'`" = "8" ] && echo ybF && exit




if [ ! -e $dUdL ];then
    [ "$calcdone" = "yes" ] && [ "$chargeok" = "yes" ] && echo yes
    [ "$calcdone" = "no"  ] && [ "$chargeok" = "yes" ] && echo no
    [ "$calcdone" = "yes" ] && [ "$chargeok" = "no" ] && [ "$eleok" = "yes" ] && echo yes
    [ "$calcdone" = "yes" ] && [ "$chargeok" = "no" ] && [ "$eleok" = "no"  ] && echo yCD #-e "\033[31m\033[1myCD\033[0m"
    [ "$calcdone" = "no"  ] && [ "$chargeok" = "no" ] && [ "$eleok" = "yes" ] && echo no
    [ "$calcdone" = "no"  ] && [ "$chargeok" = "no" ] && [ "$eleok" = "no"  ] && echo nCD #-e "\033[31m\033[1mnCD\033[0m"
fi

if [ -e $dUdL ] && [ $dUdLok = yes ];then
    [ "$calcdone" = "yes" ] && [ "$chargeok" = "yes" ] && echo yes
    [ "$calcdone" = "no"  ] && [ "$chargeok" = "yes" ] && echo no
    [ "$calcdone" = "yes" ] && [ "$chargeok" = "no" ] && [ "$eleok" = "yes" ] && echo yes
    [ "$calcdone" = "yes" ] && [ "$chargeok" = "no" ] && [ "$eleok" = "no"  ] && echo -e "\033[31m\033[1myCD\033[0m"
    [ "$calcdone" = "no"  ] && [ "$chargeok" = "no" ] && [ "$eleok" = "yes" ] && echo no
    [ "$calcdone" = "no"  ] && [ "$chargeok" = "no" ] && [ "$eleok" = "no"  ] && echo -e "\033[31m\033[1mnCD\033[0m"
fi

if [ -e $dUdL ] && [ $dUdLok = NaN ];then
echo -e "\033[31m\033[1mNaN\033[0m"
fi

