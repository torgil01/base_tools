#!/bin/bash
# collect images from dir and copy to dest dir
# images are renamed with base dir 

function usage { 
  echo "$0  -i <image directory>  -f <image-name> -d <dest dir>  [-c id-list] "
}

# test for empty args
if [ $# -eq 0 ] 
    then
      usage
      exit 2
fi

# parse args
while getopts "i:f:d:c:" flag
do
  case "$flag" in
    i)
      imDir=$OPTARG
      ;;
    f)
      fileName=$OPTARG
      ;;    
    d)
      destDir=$OPTARG
      ;;    
    c)
      idList=$OPTARG
      ;;    
    h|?)
      echo $flag
      usage
      exit 2
      ;;
  esac
done

if [ ! -z "$idList" ]; then
    # only copy data with ID from CSV file 
    # assume that the file have only one col with full ID
    while IFS=" " read col1 
    do
	ID[$i]=${col1}
	i=$((i+1))
    done < ${idList}

    for id in ${ID[@]}; do
	thisStudy=${imDir}/${id}
	target=`find "$thisStudy" -type f -name "$fileName"`
	if [ -e "$target" ]; then
	    fn=`basename $target` 
	    echo cp $target ${destDir}/${id}_${fn}
	    cp $target ${destDir}/${id}_${fn}
	else
	    echo "$id is missing $target"
	    exit -1 
	fi
    done

else
    # copy data from all IDs -- not using list        
    # loop over files in image dir
    # since we do not know how deep within each subjects dir the
    # file is located, we do this to know which ID the file is associated with
    subjDirs=(`find $imDir -maxdepth 1 -mindepth 1 -type d`)
    for d in ${subjDirs[@]}; do
	target=`find "$d" -type f -name "$fileName"`
	id=`basename "$d"`	
	if [ -e "$target" ]; then
	    fn=`basename $target` 
	    echo cp $target ${destDir}/${id}_${fn}
	    cp $target ${destDir}/${id}_${fn}
	fi    
    done
fi



