#!/bin/bash
# Create a mean image using ants` ImageMath
# The scrip find all files under <imDir> called <fileName>
# creates a mean image of these called <meanImage>
# Usage:
#   averageImages.sh -i <image directory>  -f <image-name> -m <mean_img>  [-c id-list]
# Note when using the -R <replaceImage> opt
# the image dimensions must me the same as the other images
# The R option can be used for computing total means of images where some may be missing
# for some IDs 
# TODO:
#  -use regexp in find command

function usage { 
  echo "$0  -i <image directory> -f <image-name> -m <mean_img>  [-c id-list] [-R replace-img] [-s sigma]"
}

# test for empty args
if [ $# -eq 0 ] 
    then
      usage
      exit 2
fi

# parse args
while getopts "i:f:m:c:R:s:" flag
do
  case "$flag" in
    i)
      imDir=$OPTARG
      ;;
    f)
      fileName=$OPTARG
      ;;    
    m)
      meanImage=$OPTARG
      ;;    
    c)
      idList=$OPTARG	  
      ;;
    R)
	replaceImage=$OPTARG
	;;
    s)
	sigma=$OPTARG
	;;
    h|?)
      echo $flag
      usage
      exit 2
      ;;
  esac
done

indx=0
if [ ! -z "$idList" ]; then
    # only copy data with ID from CSV file 
    # assume that the file have only one col with full ID
    while IFS=$'\n\t ' read col1 
    do
	ID[$i]=${col1}
	i=$((i+1))
    done < ${idList}

    for id in ${ID[@]}; do
	thisStudy=${imDir}/${id}
	target=`find "$thisStudy" -type f -name "$fileName"`
	if [ -e "$target" ]; then
	    files[$indx]="$target"
	    indx=$((indx+1))
	else
	    if [ ! -z "$idList" ]; then
		files[$indx]="$replaceImage"
		indx=$((indx+1))
	    else
		echo "$id is missing $target"
		exit -1 
	    fi
	fi
    done

else
    files=(`find $imDir -type f -name $fileName`)
fi

echo " averaging:"
for fi in ${files[@]}; do
    echo "$fi"
done

##################
# main
##################
tempdir=/tmp/tmp_$RANDOM
mkdir $tempdir
a=${tempdir}/tempa.nii.gz
csum=${tempdir}/csum.nii.gz
# number of files
nFiles=${#files[@]}

# check if we should smooth img before averaging
if [ ! -z "$sigma" ]; then
    stmp=${tempdir}/smooth.nii.gz
    ImageMath 3 $a G ${files[0]} "$sigma"
    for i in $(seq 1  $((nFiles-1))); do
	# origFile -s-> stmp	
	ImageMath 3 $stmp G ${files[$i]} "$sigma"
	# stmp -add-> csum 
	ImageMath 3 $csum + $a $stmp  # csum = a + f
	mv -f $csum $a  # csum -> a
	rm $stmp
    done    
else
    cp ${files[0]} $a
    for i in $(seq 1  $((nFiles-1))); do
	ImageMath 3 $csum + $a ${files[$i]}  # csum = a + f
	mv -f $csum $a  # csum -> a
    done
fi
# compute average
#         dim out      op in1 in2
ImageMath 3 $meanImage / $a $nFiles  
rm -rf  $tempdir


