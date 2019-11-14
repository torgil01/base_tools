#!/bin/bash

function usage {
  echo "List significant clusters in randomise/palm stat files"
  echo "Usage:  "
  echo "$0  path"
  echo " OR"
  echo   echo "$0 -t tresh -f path"
  echo "         -t tresh: treshold to be used"
  echo "         -f path: path to directory"
  echo "         -p [palm|randomise|fdr-tfce|fdr-vox|uncorr]"
  echo "         [-e min-cluster-size]"
}

listFiles() 
{
red='\033[0;31m'
NC='\033[0m' # No Color
THR=$2
FT=$3
EX=$4
#randomises stat files
case $FT in
    "palm")
	FILES=(${1}/"*_tfce_tstat_fwep*")
	;;
    "randomise")
	FILES=(${1}/"*_tfce_corrp*")
	;;
    "fdr-tfce")
	FILES=(${1}/"*_tfce_tstat_fdrp*")
	;;
    "fdr-vox")
	FILES=(${1}/"*_vox_tstat_fdrp*")
	;;
    "uncorr")
	FILES=(${1}/"*_vox_tstat_uncp*")
	;;
    ?)
    echo "Incorrect option to -p;  $flag. Use one of [palm|randomise|fdr-tfce|fdr-vox|uncorr]"
    usage
    exit 2
    ;;
esac
echo $files
if [ -z $EX ]; then 
    # no cluster extent
    for file in $FILES
    do
	echo -e "${red}File $file${NC}"
	cluster --in=$file --thresh=$THR 
    done
else
    for file in $FILES
    do
	echo -e "${red}File $file${NC}"
	cluster --in=$file --thresh=$THR --minextent=${EX}
    done
fi
    
}

# defaults
THR=0.95
FIDIR=$1
FT="randomise"
while getopts "ht:f:p:e:" flag
do
  case "$flag" in
    t)
	THR=$OPTARG
	;;
    f)
	FIDIR=$OPTARG
	;;
    p)
	FT=$OPTARG
	;;
    e)
	EX=$OPTARG
	;;    
    h|?)
      echo $flag
      usage
      exit 2
      ;;
  esac
done

#echo listFiles $FIDIR $THR $FT
listFiles $FIDIR $THR $FT $EX
