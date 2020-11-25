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
STEP=${1:-'3'}
PhaseName="Q-Al-Mg-Si-Cu"
INIpath="/u/alizen/projects/Q/steps"

###################################
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
 # MAIN
 #######
clear
ls
echo "*********************************"
echo "Hello, "$USER"."
echo "***********"
echo "Murn step # "$STEP
echo "***********"
echo "From compound # "$CMIN"  to compound # "$CMAX
echo "***********"

createSubmissionScript.sh

WorkDir=`pwd`
echoblue "WorkDir:"
echo $WorkDir
cd $PhaseName
hereEM=`pwd`
echoblue "End members"

##############################
for DIR  in `seq $CMIN $CMAX`; do
##############################
    echo "step = $STEP ************ directory = $DIR **********"
    cd $DIR
    VAR=`expr $STEP - 1`
    cd murn$VAR/ && folder=`ls -1d [0-9].*` && cd -
    # initialisation
    mkdir murn$STEP
    cd murn$STEP
    cp $INIpath/INCAR.m$STEP INCAR
    cp $INIpath/KPOINTS.m$STEP KPOINTS
    ln ../POTCAR
    for a in $folder; do
        echored $a
        mkdir $a
        cd $a
        cp ../INCAR ./
        cp ../KPOINTS ./
        ln -s ../POTCAR 
        cp ../../murn$VAR/$a/CONTCAR POSCAR
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
