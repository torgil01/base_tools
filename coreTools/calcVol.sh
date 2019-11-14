#!/bin/bash
# Calculate volume in binary masks

function usage {
  echo "Calculate volume of binary mask or a thresholded image"
  echo "the scrip searces trough a study dir for all matches on filename "
  echo " and return volume in cubic mm"
  echo "Usage:  "
  echo "$0  -i <image directory>  -f <image-name> [-t <threshold>]"
}

# test for empty args
if [ $# -eq 0 ] 
then
    echo "Missing arguments" 
    usage
    exit 2
fi

threshold=0
# parse args
while getopts ":i:f:t:" flag
do
  case "$flag" in
    i)
      imDir=$OPTARG
      ;;
    f)
      fileName=$OPTARG
      ;;
    t)	
      threshold=$OPTARG
      ;;
    h|?)
      echo $flag
      usage
      exit 2
      ;;
  esac
done

files=`find $imDir -name $fileName`
for file in ${files[@]}; do
    vol=`fslstats $file -l $threshold -V | awk '{print $2}'`    
    echo $file $vol
done
