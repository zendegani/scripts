#!/bin/bash
#ver 2017-02-21

scriptname="subscript"
[ -e $scriptname ] && rm $scriptname


echo "################################"
echo ""
PS3='Please select the cluster: '
options=("All" "impi_hydra_cmfe" "impi_hydra" "impi_hydra_small" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "impi_hydra")
            echo "you chose impi_hydra"
            cluster="impi_hydra"
            break
            ;;
        "impi_hydra_cmfe")
            echo "you chose impi_hydra_cmfe"
            cluster="impi_hydra_cmfe.*"
            break
            ;;
        "impi_hydra_small")
            echo "you chose impi_hydra_small"
            cluster="impi_hydra_small"
            break
            ;;
        "All")
            echo "you chose all"
            cluster="impi_hy*"
            break
            ;;
        "Quit")
            rm $scriptname
            exit
            ;;
        *) echo invalid option;;
    esac
done


echo "################################"
echo ""
PS3='Please select VASP version: '
options=("5.4.1" "5.4.1 I_CONSTRAINED_M=1/2" "5.3.5 I_CONSTRAINED_M=4" "5.3.5 Cartesian relaxation" "5.4.1 relax c_z vector" "5.4.1 relax c_xyz vector" "4.6.28" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "5.4.1 I_CONSTRAINED_M=1/2")
            echo "you chose 5.4.1 I_CONSTRAINED_M=1/2"
            vaspmodule="vasp/5.4.1"
            vaspexec="vasp_ncl"
            break
            ;;
        "5.3.5 I_CONSTRAINED_M=4")
            echo "you chose 5.3.5 I_CONSTRAINED_M=4"
            vaspmodule=""
#            vaspexec="/u/bzg/VASP_src_5/vasp.5.3.5_constrmag/vasp"
            vaspexec="/u/alizen/vasp.5.3.5_constrmag/vasp"
            break
            ;;
        "5.4.1")
            echo "you chose 5.4.1"
            vaspmodule="vasp/5.4.1"
            vaspexec="vasp"
            break
            ;;
        "5.3.5 Cartesian relaxation")
            echo "5.3.5 Cartesian relaxation"
            vaspmodule=""
            vaspexec="/u/bzg/Thermodynamics/vasp_Langevin/vasp_5.3.5/vasp"
            break
            ;;
        "5.4.1 relax c_z vector")
            echo "5.4.1  relax c_z vector"
            vaspmodule=""
            vaspexec="/u/alizen/vasp.5.4.1_localeFFT_cz_axis/bin/vasp_std"
            break
            ;;
        "5.4.1 relax c_xyz vector")
            echo "5.4.1  relax c_xyz vector"
            vaspmodule=""
            vaspexec="/u/alizen/vasp.5.4.1_localeFFT_cx_cy_cz/bin/vasp_std"
            break
            ;;
        "4.6.28")
            echo "you chose 4.6.28"
            vaspmodule="vasp/4.6.28"
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

echo "################################"
echo ""
PS3='Please select number of nodes: '
options=("other" "20"  "40"  "60" "80" "Quit")
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
        "other")
            echo "Enter number of cores (dividable by 20 for impi_hydra_cmfe and 40 for impi_hydra): "
            read nd
            break
            ;;
        "Quit")
            rm $scriptname
            exit
            ;;
        *) echo invalid option;;
    esac
done

echo "################################"
echo ""
PS3='Please select time in hours: '
options=("max72hrs" "12:0:0" "24:0:0" "36:0:0" "Quit")
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


echo "################################"
echo ""
filesrm="WAVECAR CHGCAR DOSCAR"
fileszip="DOSCAR"
PS3='Please select if you like to keep WAVECAR, CHGCAR and DOSCAR: '
options=("No" "Yes" "Quit")
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

echo "################################"
echo ""
PS3='Enable the Intel MPI Library 4.0.x compatible mode (might be required if ALGO=DAMPED and IALGO=53):'
options=("No/SKIP" "Yes" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Yes")
            echo "you enabled the Intel MPI Library 4.0.x compatible mode"
            mpi_mode="export I_MPI_COMPATIBILITY=4"
            break
            ;;
        "No/SKIP")
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
# set shell:
#$ -S /bin/bash
# join error channel into normal output:
#$ -j y
# set working directory to current directory
#$ -cwd
# request advance reservation (block nodes for multi-node jobs):
#$ -R y
#$ -m n
#$ -N meinjob
#$ -l h_rt=$hr
#$ -pe $cluster $nd
#$ -e err.log
#$ -o std.log

date
ulimit -aH
module unload impi
module load impi
module unload vasp
module load $vaspmodule
mpiexec -n \$NSLOTS $vaspexec
rm EIGENVAL PROCAR PCDAT IBZKPT CHG $filesrm
bzip2 POTCAR $fileszip std.log
bzip2 -f vasprun.xml OSZICAR
gzip -f OUTCAR

EOF

echo $mpi_mode >> $scriptname
echo "" >> $scriptname
echo "#qsub -l h_rt=$hr -pe $cluster $nd ./$scriptname"  >> $scriptname
echo "" >> $scriptname

echo ""

echo "vaspmodule: " $vaspmodule
echo "vaspexec: " $vaspexec
echo "node: #" $nd
echo "time: " $hr
chmod +x $scriptname
echo ""
echo "qsub -l h_rt=$hr -pe $cluster $nd ./$scriptname"
echo ""

