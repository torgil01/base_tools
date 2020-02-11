#!/bin/bash
# Convert "raw" study data to structured format
# Image file names with differnet names are mapped to to same name
# making automated processing easy. The file mapping is specified in the json file
#

function usage () {    
    echo "Usage: "
    echo " $0 -i <input_study_dir> -o <output_study_dir> -j <json_file>"
    echo ""
    echo "Convert "raw" study data to structured format. Image file names with \
    differnet names are mapped to to same name making automated processing easy. +
    The file mapping is specified in the json file."
}




while getopts "i:o:j:" flag
do
  case "$flag" in
    i)
      STUDY_DIR=$OPTARG
      ;;
    o)
      destDir=$OPTARG
      ;;
    j)
      json=$OPTARG
      ;;
    h|?)
      echo $flag
      usage
      exit 2
      ;;
  esac
done


# loop over study dir and find target
subjDirs=$(find $STUDY_DIR -maxdepth 1 -mindepth 1 -type d)
for d in ${subjDirs[@]}; do
    id=$(basename "$d")
    # loop over image types we want to convert
    fileNames=$(jq -r '.[] | .FNAME | @text' ${json})
    for FNAME in ${fileNames[@]}; do
	SUBDIR=$(jq --raw-output --arg FNAME "$FNAME" 'map(select(.FNAME == $FNAME)) 
	       | .[].SUBDIR 	  
      	       | @sh'  ${json} | tr -d "'")	
	TARGETS=$(jq --raw-output --arg FNAME "$FNAME" 'map(select(.FNAME == $FNAME)) 
	       | .[].TARGETS 
      	       | @sh'  ${json} | tr -d "'")
	TARGETS=( $TARGETS )
	for t in ${TARGETS[@]}; do
	    # is the list sorted? -print0 | sort -z
	    target=$(find "$d" -type f -name "$t")
	    target=( $target )
	#mapfile -d '' target < <(find "$d" -type f -name "$t")
	#	echo "$target num=${#target[@]}"
	# test is $target is nonempty with n	
	if [[ -n $target ]]; then
	    # it there are several hits for target we must add numbers
	    # todo -- THIS DOES NOT WORK
	    if [ ${#target[@]} -gt 1 ]; then
		   # we have several targets
		   n=0
		   for tt in ${target[@]}; do
		       if [ ! -e ${destDir}/${id} ]; then
			   mkdir ${destDir}/${id}
		       fi
		       if [ ! -e ${destDir}/${id}/${SUBDIR}_${n} ]; then	       
			   mkdir ${destDir}/${id}/${SUBDIR}_${n}
		       fi
       		       # actual copy
		       if [ ! -f ${destDir}/${id}/${SUBDIR}_${n}/${FNAME} ]; then	       
			   #echo "cp $target ${destDir}/${id}/${SUBDIR}/${FNAME}"
			   # we must also add a number at the end of each new file
			   # rem ext from tt
			   ttfn=$(echo "$FNAME" | cut -f 1 -d '.');
			   ttext=$(echo "$FNAME" | cut -f 2,3 -d '.');
			   newFilename=${ttfn}_${n}.${ttext}
			   cp $tt ${destDir}/${id}/${SUBDIR}_${n}/${newFilename}
			   echo "$tt -->  ${destDir}/${id}/${SUBDIR}_${n}/${newFilename}"
		       fi
		       n=$((n+1))
		   done		   
	     else
		 if [ ! -e ${destDir}/${id} ]; then
		     mkdir ${destDir}/${id}
		 fi
		 if [ ! -e ${destDir}/${id}/${SUBDIR} ]; then	       
		     mkdir ${destDir}/${id}/${SUBDIR}
		fi
       		# actual copy
		if [ ! -f ${destDir}/${id}/${SUBDIR}/${FNAME} ]; then	       
		    echo "$target --> ${destDir}/${id}/${SUBDIR}/${FNAME}"
		    cp $target ${destDir}/${id}/${SUBDIR}/${FNAME}		    
		fi	    
		# found target exiting current loop
		#break
	    fi
	fi
	done
    done
done


# see https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash/54561526#54561526
