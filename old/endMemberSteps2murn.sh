#!/bin/bash
#Garch 2016.01.27

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;


 ################
 ### Parameters #
 ################
# Which compound
CMIN=1  # Minimal Compound number 
CMAX=48  # Maximal Compound number
# Which STEP ?
# 1,... ,6   normal
STEP=1
SourceStep=${1:-'6'}
PhaseName="Q-Al-Mg-Si-Cu"
INIpath="/u/alizen/projects/Q/steps"



###################################
 ################
 ### Functions ##
 ################
 # Prepa POSCAR
 ################
 preparposcar() 
 {
 if [ $STEP -eq 1 ] ; then
 # new POSCAR
   cp ../$SourceStep/CONTCAR POSCAR
 else
   echored "########### Error: it is not ready for murn further step"
   VAR=`expr $STEP - 1`
   cp ../$VAR/CONTCAR POSCAR
 fi
 }
 ################
 # VASP execution 
 ################
 execution()
 {
    echo $PWD
    echo "***********"
    cp $WorkDir/subscript .
    qsub subscript
 }



###################################
 #######
 # MAIN     
 #######
clear
ls
echo "*********************************"
echo "***********"
echo "Hello, "$USER"." 
echo "***********"
echo "Murn step #"$STEP"
echo "***********"
echo "From compound #"$CMIN" to compound #"$CMAX"
echo "***********"

createSubmissionScript.sh

WorkDir=`pwd`
echoblue "WorkDir:"
echo $WorkDir
cd $PhaseName
hereEM=`pwd`
echoblue "End members"


#--- Define universal scaling factor ('lattice constant') range
echoblue "Define universal scaling factor ('lattice constant') range, eg., 0.98 0.99 1.00 1.01 1.02 "
read -p "Range start [0.98] : " rangestart
rangestart=${rangestart:-"0.98"}
read -p "Range end [1.02] : " rangeend
rangeend=${rangeend:-"1.02"}
read -p "Range step [0.01] : " rangestep
rangestep=${rangestep:-"0.01"}
echogreen $rangestart $rangestep $rangeend

lat=`awk 'BEGIN{ for (i='$rangestart'; i <= '$rangeend'; i+='$rangestep') printf("%.2f\n", i); }'`

##############################
for DIR  in `seq $CMIN $CMAX`; do
##############################
    echo "step = $STEP ************ directory = $DIR **********"
    cd $DIR
    mkdir murn$STEP
    cd murn$STEP
    # initialisation
    preparposcar
    cp $INIpath/INCAR.m$STEP INCAR
    cp $INIpath/KPOINTS.m$STEP KPOINTS
    ln ../POTCAR
    #

    for a in $lat; do
        echored $a
        mkdir $a
        cd $a

        cp ../INCAR ./
        cp ../KPOINTS ./
        ln -s ../POTCAR 
        cp ../POSCAR ./

        #--- prompt user info
        echo "-------------------------------------------------------"
        echo "  End-member $DIR : Lat. coef. = $a"
        echo "-------------------------------------------------------"

        #--- create POSCAR
        n=`echo $(wc -l < POSCAR)-2 | bc`
        mv POSCAR POSCARtmp
        head -1 POSCARtmp > POSCAR
        cat >> POSCAR << POSCAReof
$a
POSCAReof
        tail -$n POSCARtmp >> POSCAR
        execution
        cd ../
    done
    cd $hereEM
##############################
done
##############################
echo "*********************************"
cd $WorkDir
rm subscript;
exit 0;
###################################
###################################

