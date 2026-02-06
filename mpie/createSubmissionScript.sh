#!/bin/bash
#ver 2020-02-19

scriptname="subscript"
[ -e $scriptname ] && rm $scriptname


echo "################################"
echo ""
PS3='Choose the cluster: '
options=("s.cmfe" "p.cmfe" "All" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "s.cmfe")
            echo "you chose s.cmfe"
            cluster="#SBATCH --partition=s.cmfe"
            mempercpu='#SBATCH --mem-per-cpu=3GB             # Job memory request'
            break
            ;;
        "p.cmfe")
            echo "you chose p.cmfe"
            cluster="#SBATCH --partition=p.cmfe"
            break
            ;;
        "All")
            echo "you chose all"
            cluster=""
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
PS3='Choose the node type: '
options=("cmfe" "cmti" "All" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "cmfe")
            echo "you chose s.cmfe"
            node="#SBATCH --constraint=cmfe"
            break
            ;;
        "cmti")
            echo "you chose p.cmfe"
            node="#SBATCH --constraint=cmti"
            break
            ;;
        "All")
            echo "you chose all"
            node=""
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
PS3='Choose VASP version: '
options=("5.4.4 Feb20 std"  "5.4.4 Feb20 ncl"  "5.4.4 ncl patched ICM4"  "5.3.5 ncl patched ICM4"  "5.4.4 std" "5.4.4 ncl"  "5.3.5 Cartesian relaxation" "5.4.1 relax c_z vector" "5.4.1 relax c_xyz vector" "5.4.4 std old" "5.4.1 std old" "5.4.4 ncl old"  "5.4.1 ncl old" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "5.4.4 Feb20 std")
            echo "you chose vasp/5.4.4 Feb20 std"
            vaspmodule="vasp/5.4.4-buildFeb20 intel/19.1.0 impi/2019.6"
            vaspexec="vasp_std"
            break
            ;;
        "5.4.4 Feb20 ncl")
            echo "you chose vasp/5.4.4 Feb20 ncl"
            vaspmodule="vasp/5.4.4-buildFeb20 intel/19.1.0 impi/2019.6"
            vaspexec="vasp_ncl"
            break
            ;;
        "5.4.4 ncl patched ICM4")
            echo "you chose vasp/5.4.4 ncl patched ICM4"
            vaspmodule="vasp/5.4.4-Dudarev intel/19.1.0 impi/2019.6"
            vaspexec="vasp_ncl"
            break
            ;;
        "5.4.4 std")
            echo "you chose vasp/5.4.4 std"
            vaspmodule="vasp/5.4.4 intel/19.0.5 impi/2019.5"
            vaspexec="vasp_std"
            break
            ;;
        "5.4.4 ncl")
            echo "you chose vasp/5.4.4 ncl"
            vaspmodule="vasp/5.4.4 intel/19.0.5 impi/2019.5"
            vaspexec="vasp_ncl"
            break
            ;;
        "5.4.4 std old")
            echo "you chose old vasp/5.4.4 std"
            vaspmodule="oldvasp/5.4.4 intel/18.0.5 impi/2018.4"
            vaspexec="vasp"
            break
            ;;
        "5.4.4 ncl old")
            echo "you chose old vasp/5.4.4 ncl"
            vaspmodule="oldvasp/5.4.4 intel/18.0.5 impi/2018.4"
            vaspexec="vasp_ncl"
            break
            ;;
        "5.4.1 std old")
            echo "you chose old vasp/5.4.1 std"
            vaspmodule="oldvasp/5.4.1 intel/18.0.5 impi/2018.4"
            vaspexec="vasp"
            break
            ;;
        "5.4.1 ncl old")
            echo "you chose old vasp/5.4.1 ncl"
            vaspmodule="oldvasp/5.4.1 intel/18.0.5 impi/2018.4"
            vaspexec="vasp_ncl"
            break
            ;;
        "5.3.5 Cartesian relaxation")
            echo "old 5.3.5 Cartesian relaxation"
            vaspmodule="intel/18.0.5 impi/2018.4"
            vaspexec="/u/bzg/Thermodynamics/vasp_Langevin/vasp_5.3.5/vasp"  # not sure if re-compiled yet 
            break
            ;;
        "5.4.1 relax c_z vector")
            echo "old 5.4.1  relax c_z vector"
            vaspmodule="intel/18.0.5 impi/2018.4"
            vaspexec="/u/alizen/vasp.5.4.1_localeFFT_cz_axis/bin/vasp_std" # should re-compile
            break
            ;;
        "5.4.1 relax c_xyz vector")
            echo "old 5.4.1  relax c_xyz vector"
            vaspmodule="intel/18.0.5 impi/2018.4"
            vaspexec="/u/alizen/vasp.5.4.1_localeFFT_cx_cy_cz/bin/vasp_std" # should re-compile
            break
            ;;
        "5.3.5 ncl patched ICM4")
            echo "you chose vasp/5.3.5 ncl patched ICM4"
            vaspmodule="intel/18.0.5 impi/2018.4"
#            vaspexec="/u/bzg/VASP_src_5/vasp.5.3.5_constrmag/vasp"
            vaspexec="/u/alizen/vasp.5.3.5_constrmag/vasp"   # should re-compile
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
PS3='Please select number of cores: '
options=("1"  "20"  "40"  "80"  "other"  "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "1")
            echo "you chose 1"
            nd="1"
            break
            ;;
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
        "80")
            echo "you chose 80"
            nd="80"
            break
            ;;
        "other")
            echo "Enter number of cores (dividable by 40 for cmfe): "
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
PS3='Please select running time: "minutes", "minutes:seconds", "hours:minutes:seconds", "days-hours", "days-hours:minutes" and "days-hours:minutes:seconds"'
options=("06:0:0" "12:0:0" "24:0:0" "max96hrs" "other" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "06:0:0")
            echo "you chose 06:0:0"
            hr="06:0:0"
            break
            ;;
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
        "max96hrs")
            echo "you chose maximum possible 96 hrs"
            hr="3-23:30:00"
            break
            ;;
        "other")
            echo "Enter the amount of running time in format 'days-hours:minutes:seconds': "
            read hr
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
read -p "Enter job(s) name [meinjob]: " jobname 
jobname=${jobname:-"meinjob"}

#echo "################################"
#echo ""
#PS3='Enable the Intel MPI Library 4.0.x compatible mode (might be required if ALGO=DAMPED and IALGO=53):'
#options=("No/SKIP" "Yes" "Quit")
#select opt in "${options[@]}"
#do
#    case $opt in
#        "Yes")
#            echo "you enabled the Intel MPI Library 4.0.x compatible mode"
#            mpi_mode="export I_MPI_COMPATIBILITY=4"
#            break
#            ;;
#        "No/SKIP")
#            break
#            ;;
#        "Quit")
#            rm $scriptname
#            exit
#            ;;
#        *) echo invalid option;;
#    esac
#done

# echo "################################"
# echo ""
# mempercpu=''
# if [ $nd -lt 40 ]
#   then
#     echo 'Number of Cores are less than 40, so only 3GB is allocated to MEMORY'
#     mempercpu='#SBATCH --mem-per-cpu=3GB             # Job memory request'
# fi

if [ $nd -gt 40 ]
  then
    echo 'Number of Cores are greater than 40, so the job is constrained to switches'
    Features="#SBATCH --constraint='[swi1|swi1|swi2|swi3|swi4|swi5|swi6|swi7|swe1|swe2|swe3|swe4|swe5|swe6|swe7]'"
fi



cat > $scriptname << EOF
#!/bin/bash
#SBATCH --job-name=$jobname            # Job name
#SBATCH --mail-type=FAIL              # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=z@mpie.de # Where to send mail	
#SBATCH --ntasks=$nd                   # Run on #nd CPU
#SBATCH --time=$hr              # Time limit days-hrs:min:sec
#SBATCH --output=std.log              # Standard output and error log
#SBATCH --error=err.log
$cluster
$node
$mempercpu
$Features

pwd; hostname; date
echo jobid \$SLURM_JOB_ID

module purge
module load $vaspmodule

srun -n $nd $vaspexec

rm EIGENVAL PROCAR PCDAT IBZKPT CHG $filesrm
bzip2 POTCAR $fileszip std.log err.log
bzip2 -f vasprun.xml OSZICAR 
gzip -f OUTCAR

date

EOF

echo "" >> $scriptname
echo "#sbatch ./$scriptname" >> $scriptname
echo "" >> $scriptname

echo "vaspmodule: "$vaspmodule
echo "vaspexec:   "$vaspexec
echo "cores:      #"$nd
echo "time:       "$hr
chmod +x $scriptname
echo ""
echo "sbatch ./$scriptname"
echo ""


##SBATCH --constraint=cmti             # only run on cmti
##SBATCH --partition=$cluster

