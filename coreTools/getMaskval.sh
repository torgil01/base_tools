#!/bin/bash
# mask image and get average value in mask 

function usage {
  echo "compute average in mask for images"
  echo "the scrip searces trough a study dir for all matches on filename "
  echo "Usage:  "
  echo "$0  -i <image directory>  -f <image-name> -m <maskName>"
}

# test for empty args
if [ $# -eq 0 ] 
    then
      usage
      exit 2
fi

# parse args
while getopts "i:f:m:" flag
do
  case "$flag" in
    i)
	imDir=`readlink -f $OPTARG`	
	;;
    f)
      fileName=$OPTARG
      ;;
    m)
	maskName=$OPTARG
	;;
    h|?)
      echo $flag
      usage
      exit 2
      ;;
  esac
done

#tmpfile=/tmp/tmp.nii.gz
echo "fileName=$fileName maskName=$maskName imDir=$imDir"
echo "id globMean roiMean"
WD=(`find $imDir -maxdepth 1 -mindepth 1 -type d`)
for subjdir in ${WD[@]}; do
    im=`find $subjdir -type f -name $fileName`
    id=`basename $subjdir`
    mask=`find $subjdir -type f -name $maskName`
    #echo "mask=$mask"
    #echo "im=$im"
    if [ -f "$im" ] && [ -f "$mask" ]; then
	#if [ -f $tmpfile ]; then
	 #   rm $tmpfile
	#fi
	# more efficient with fslstats
	#fslmaths $im -mul $mask $tmpfile
	#echo "subjDir=$subjdir"      
	# note that mask must be the first option in fslstats!
	# val=$(fslstats  $im -k $mask -m -s -M -S )
	val=$(fslstats  $im -M -k $mask -m  )
	# mean wo zeros
	#val=`fslstats $tmpfile -M`
	#rm $tmpfile
	echo $id $val
	# > $datFile
    fi
done
