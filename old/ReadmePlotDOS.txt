you can do it by extracting columns with simple regex like sed, awk and grep and use gnuplot for example. the structure of the file is:

E DOS Integr. DOS (usually 300 lines)

site resolved

E s p d (+spin if ISPIN=2)

here is some hint:

cat DOSCAR| sed -n 7,307p > dos.txt (for full and integrated)

cat dos.txt |awk '{print $1-(E-Fermi)" "$2" "$3}' > f_dos.txt (to shift Ef to 0)

then you can modify for the lines and columns as required. PROCAR is bit more complex, but in principle simple linux shell commands will get you going. 


