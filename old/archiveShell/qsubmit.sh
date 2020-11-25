#!/bin/bash

scriptname="subscript"

echo ""
PS3='Please select VASP version: '
options=("5.4.1 NONCOLLINEAR" "5.3.5 NEWCONSTRAINS" "5.4.1" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "5.4.1 NONCOLLINEAR")
            echo "you chose 5.4.1 NONCOLLINEAR"
            vaspmodule="vasp/5.4.1"
            vaspexec="vasp_ncl"
            break
            ;;
        "5.3.5 NEWCONSTRAINS")
            echo "you chose 5.3.5 NEWCONSTRAINS"
            vaspmodule=""
            vaspexec="/u/bzg/VASP_src_5/vasp.5.3.5_constrmag/vasp"
            break
            ;;
        "5.4.1")
            echo "you chose 5.4.1"
            vaspmodule="vasp/5.4.1"
            vaspexec="vasp"
            break
            ;;
        "Quit")
            rm $scriptname
            exit
            ;;
        *) echo invalid option;;
    esac
done

echo ""
PS3='Please select number of nodes: '
options=("20" "40" "60" "80" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "20")
            echo "you chose 20"
            nd="20"
            break
            ;;
        "40")
            echo "you chose 40"
            nd="40"
            break
            ;;
        "60")
            echo "you chose 60"
            nd="60"
            break
            ;;
        "80")
            echo "you chose 80"
            nd="80"
            break
            ;;
        "Quit")
            rm $scriptname
            exit
            ;;
        *) echo invalid option;;
    esac
done

echo ""
PS3='Please select time in hours: '
options=("12:0:0" "24:0:0" "36:0:0" "max72hrs" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "12:0:0")
            echo "you chose 12:0:0"
            hr="12:0:0"
            break
            ;;
        "24:0:0")
            echo "you chose 24:0:0"
            hr="24:0:0"
            break
            ;;
        "36:0:0")
            echo "you chose 36:0:0"
            hr="36:0:0"
            break
            ;;
        "max72hrs")
            echo "you chose maximum possible 72 hrs"
            hr="259199"
            break
            ;;
        "Quit")
            rm $scriptname
            exit
            ;;
        *) echo invalid option;;
    esac
done

echo ""
filesrm="WAVECAR CHGCAR"
fileszip="WAVECAR CHGCAR"
PS3='Please select if you like to keep WAVECAR and CHGCAR: '
options=("Yes" "No" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Yes")
            echo "you chose Yes"
            filesrm=""
            break
            ;;
        "No")
            echo "you chose No"
            fileszip=""
            break
            ;;
        "Quit")
            rm $scriptname
            exit
            ;;
        *) echo invalid option;;
    esac
done

cat > $scriptname << EOF
#$ -S /bin/bash
#$ -j y
#$ -cwd
#$ -m n
#$ -N meinjob
#$ -l h_rt=259199
#$ -pe impi_hydra 20
date
ulimit -aH
module load impi
module load $vaspmodule
mpiexec -n \$NSLOTS $vaspexec
rm DOSCAR EIGENVAL PROCAR PCDAT IBZKPT CHG $filesrm
gzip vasprun.xml OUTCAR POTCAR OSZICAR $fileszip

#qsub -l h_rt=$hr -pe impi_hydra $nd ./$scriptname

EOF

echo ""

echo "vaspmodule: " $vaspmodule
echo "vaspexec: " $vaspexec
echo "node: #" $nd
echo "time: " $hr
chmod +x $scriptname
echo ""
echo "qsub -l h_rt=$hr -pe impi_hydra $nd ./$scriptname"
echo ""
qsub -l h_rt=$hr -pe impi_hydra $nd ./$scriptname

