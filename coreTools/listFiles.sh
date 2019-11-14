#!/bin/bash
# search image dir for a certain filename
# and make a list of ID and true/false if it exist
# Best practice is to use TRUE/FALSE since this is
# parsed as logicals in R.

function usage { 
  echo "$0  -i <image directory>  -f <image-name1,image-name2,..>"
}

# test for empty args
if [ $# -eq 0 ] 
    then
      usage
      exit 2
fi

# parse args
while getopts "i:f:" flag
do
  case "$flag" in
    i)
      imDir=$OPTARG
      ;;
    f)
      fileNames=$OPTARG
      ;;    
    h|?)
      echo $flag
      usage
      exit 2
      ;;
  esac
done

# loop over files in mage dir
# since we do not know how deep within each subjects dir the
# file is located, we do this to know which ID the file is associated with
# header
printf "ID,folder.count,%s\n" "$fileNames"

subjDirs=(`find $imDir -maxdepth 1 -mindepth 1 -type d`)
for d in ${subjDirs[@]}; do
    id=`basename "$d"`
    folders=$(ls -l $d | grep -c ^d)
    printf "%s,%s" "$id" "$folders"    
    IFS=','
    for fileName in ${fileNames[@]}; do
	target=`find "$d" -type f -name "$fileName"`
	if [ -e "$target" ]; then
	    printf ",TRUE"
	else
	    printf ",FALSE"
	fi
    done
    printf "\n"
done



