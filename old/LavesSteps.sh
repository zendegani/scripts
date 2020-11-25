#!/bin/bash
#Garch 2016.01.22

path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;


 ################
 ### Parameters #
 ################
# Which compound
#CMIN=1  # Minimal Compound number
#CMAX=48  # Maximal Compound number
# Which STEP ?
# 1,... ,6   normal
STEP=${1:-'2'}
PhaseName="Laves"
INIpath="/u/alizen/steps"
echoblue "Settings read from $INIpath"


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
   cp ../POSCAR .
 else
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
echo "Hello, "$USER"."
echo "***********"
echo "Step #"$STEP"
echo "***********"
#echo "From compound #"$CMIN" to compound #"$CMAX"
#echo "***********"

createSubmissionScript.sh

WorkDir=`pwd`
echoblue "WorkDir:"
echo $WorkDir
#cd $PhaseName
#hereEM=`pwd`
#echoblue "End members"

##############################
#for DIR  in `seq $CMIN $CMAX`; do
##############################
# echo "step = $STEP ************ directory = $DIR **********"
# cd $DIR
 mkdir $STEP
 cd $STEP
# initialisation
 preparposcar
 cp $INIpath/INCAR.$STEP INCAR
 cp $INIpath/KPOINTS.$STEP KPOINTS
 ln ../POTCAR
 #
 execution
# cd $hereEM
##############################
#done
##############################
echo "*********************************"
cd $WorkDir
rm subscript;
exit 0;
###################################
###################################

