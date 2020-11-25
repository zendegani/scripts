#!/bin/bash
#ver 2015-11-12

# following 3 lines must always be present
path=`set | grep BASH_SOURCE | sed 's|.*\"\(.*\)/[^/]*\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
script=`set | grep BASH_SOURCE | sed 's|.*\".*/\([^/]*\)\".*|\1|' | sed '/BASH_SOURCE=/s/.*/\./'`
options=$*; . $path/azfunctions.include;

switches="[-i FILE] [-h] "
while getopts "i:h" opt; do
  case $opt in
    i)
      input="$OPTARG"
      echo "Input file set as: $input" >&2
      ;;
    h)
      usage $script
      echoblue $switches
      echo2 "Options: "\
              "        -i  FILE         Default input file is POSCAR. "\
              "        -h               Print this help" >&2
      echo ""
      exit 0
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage $script
      echoblue $switches
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage $script
      echoblue $switches
      exit 1
      ;;
  esac
done

input=${input:-"POSCAR"}
vectorFile='vectors.dat'
vectors=`head -5 $input | tail -3`
echo "$vectors"
echo "$vectors" > $vectorFile

echogreen "Loading modules on the cluster ..."
module load python27/cython/0.23
echoblue "done!"
pythonFile='printAngle.py'
echogreen "Generating python script ..."

cat > $pythonFile << EOF

import numpy as np
import math

def dotproduct(v1, v2):
  return sum((a*b) for a, b in zip(v1, v2))

def length(v):
  return math.sqrt(dotproduct(v, v))

def angle(v1, v2):
  return math.degrees(math.acos(dotproduct(v1, v2) / (length(v1) * length(v2))))

vectors=np.loadtxt('$vectorFile')
print 'Angle between V1 and V2: ', angle(vectors[0],vectors[1])
print 'Angle between V1 and V3: ', angle(vectors[0],vectors[2])
print 'Angle between V2 and V3: ', angle(vectors[1],vectors[2])

EOF

echoblue "done!"
echogreen "Calling python script"
python $pythonFile
echoblue "End of python execution!"

rm $vectorFile $pythonFile

