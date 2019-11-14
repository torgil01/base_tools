#!/bin/bash

# deploy image data
# optionally only copy certain series dir

function usage { 
    echo "$0  -i <source dir>  -o <deploy dir> -n \"<dest dir>\""    
}

# test for empty args
if [ $# -eq 0 ] 
    then
      usage
      exit 2
fi

# parse args
while getopts "i:o:n:" flag
do
  case "$flag" in
    i)
      SDIR=$OPTARG
      ;;
    o)
      DDIR=$OPTARG
      ;;    
    n)
      TDIR=$OPTARG
      ;;    
    h|?)
      echo $flag
      usage
      exit 2
      ;;
  esac
done


#echo $SDIR
#echo $DDIR
#echo $TDIR
#exit 0


# source dir
#SDIR=/home/torgil/Projects/AD/3t_MRI/TBSS/niiFull/
#SDIR=/home/torgil/Projects/AD/Misbah/test/

# destination dir
#DDIR=/home/torgil/Projects/AD/Misbah/img/

# these are the dirs to be copied
#TDIR=(FLAIR T1)

# loop over study dir and find target
subjDirs=(`find $SDIR -maxdepth 1 -mindepth 1 -type d`)
for d in ${subjDirs[@]}; do
    id=`basename "$d"`
    for t in ${TDIR[@]}; do
	sourceSeriesDir=${d}/${t}
	if [[ -e $sourceSeriesDir ]]; then	    
	    if [[ ! -d ${DDIR}/${id} ]]; then	    
		echo mkdir ${DDIR}/${id}
		mkdir ${DDIR}/${id}
	    fi
	    cp -r $sourceSeriesDir ${DDIR}/${id}/${t}
	fi
    done
done



