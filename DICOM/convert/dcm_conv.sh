#!/bin/bash
# trv 03092015
# tested on Siemens & Philips DICOM 
# 021115 added single/multi mode
# 140916 added -b option for creation json files
#        Note that there is need to explicitly move the file into subfo
#        see bids.neuroimaging.io
# 251017 Added -m dirName option which assume that DICOM data is sorted into
# subforlders for each series. With this option, the original dir names are kept
# for the nii files

function usage {
  echo "Convert DICOM files to nii.gz using dcm2niix."
  echo "** NOTE: assume that input directory contains one sub-dir for each subject"
  echo "Usage:  "
  echo "$0  [-m <multi|single|hunt|dirName>] -D <DICOM directory> -o <nii directory> [-i]" 
  echo "          -o Output directory"
  echo "          -m multi   :  assume multi subject directory"
  echo "          -m single  :  assume single-subject directory"
  echo "          -m hunt    :  special for HUNT data"
  echo "          -m p65     :  special for P65 data"
  echo "          -m dirName :  convert "
  echo "          -i         :  ignore derived images "
  echo "          -h         :  this page "
  


}

# test for empty args
if [ $# -eq 0 ] 
    then
      usage
      exit 2
fi
# parse args
MODE="single"
IGNORE=false
while getopts "hiD:o:m:" flag
do
  case "$flag" in
    D)
      DICOMDIR=$OPTARG
      ;;
    o)
      OUTDIR=$OPTARG
      ;;
    m)
      MODE=$OPTARG
      ;;
    i)
      IGNORE=true
      ;;    
    h|?)
      echo $flag
      usage
      exit 2
      ;;
  esac
done


# set naming string for dcm2niix
fileNamingPattern="%4s_%p" # series_protocol name
fileNamingPattern="%4s_%d" # series#_seriesDescription


case  "$MODE" in
    multi)
        # assume that DICOMDIR is a "subject folder" subfolders is ID
	SUBJ=${DICOMDIR}/*
	for d in ${SUBJ[@]}; do 
	    if [ -d "$d" ]; then	
		DEST_DIR=$OUTDIR/$(basename ${d} .)
		mkdir $DEST_DIR		
		# convert to nifi with dcm2niix
		# -z y == pigz -z i == internal gz
		# pigz cause buffer overflow for some images, but is faster
		# Note beta -i y => ignore drived 
		if [ "$IGNORE" = true ] ; then 
		    dcm2niix -o $DEST_DIR -f "$fileNamingPattern" -z i -s y -b y -i y  $d
		else
		    dcm2niix -o $DEST_DIR -f "$fileNamingPattern" -z i -s y $d
		fi		
		START=`pwd`
		cd $DEST_DIR
		# ensure that there are no space in the filenames
		find -name "* *" -type f | rename 's/ /_/g'
                # place data into subfolders
		FILES=(*)
		for i in ${FILES[@]}; do 
                    # split filename using "_" as delim
		    FN=(${i//_/ })
		    EXT=${i#*.}
		    DIRNAME=$(basename $i .$EXT)
		    if [ ! -d "$DIRNAME" ]; then
			mkdir "$DIRNAME"
		    fi
		    TEMP=${FN[@]:1}
		    NEW_FN=${TEMP// /_}
		    mv $i $DIRNAME/$NEW_FN
		    #mv $i $DIRNAME/$TEMP
		done
		cd $START
	    fi
	done
       ;;

    single)
        # assume that DICOMDIR is a "single subject  folder" subfolders is scans
	SUBJ=$DICOMDIR
	if [ -d "$SUBJ" ]; then	
		DEST_DIR=$OUTDIR/$(basename ${SUBJ} .)
		mkdir $DEST_DIR		
	        # convert to nifty with dcm2niix
		if [ "$IGNORE" = true ] ; then 
		    dcm2niix -d 9 -o $DEST_DIR -f "$fileNamingPattern" -z i -s y -b y -i y  $SUBJ
		else
		    dcm2niix -d 9 -o $DEST_DIR -f "$fileNamingPattern" -z i -s y $SUBJ	
		fi		
		START=`pwd`
		cd $DEST_DIR
                # place data into subfolders
		FILES=(*)
		for i in ${FILES[@]}; do 
                # split filename using "_" as delim
		    FN=(${i//_/ })
		    EXT=${i#*.}
		    #DIRNAME=`basename $FN`
		    DIRNAME=`basename $i .$EXT`
		    #echo $DIRNAME
		    if [ ! -d "$DIRNAME" ]; then
			mkdir ${DIRNAME}
		    fi
		    TEMP=${FN[@]:1}
		    NEW_FN=${TEMP// /_}
		    mv "$i" $DIRNAME/$NEW_FN
		done
		cd $START
	    fi
       ;;

    hunt)
        # assume that we are dealing with HUNT DICOM data
	SUBJ=${DICOMDIR}/*
	for d in ${SUBJ[@]}; do 
	    if [ -d "$d" ]; then	
		DEST_DIR=$OUTDIR/$(basename ${d} .)
		if [ ! -d "$DEST_DIR" ]; then
		    mkdir $DEST_DIR
		fi	       
		# there is an extra dir under subj we collapse that
		SERIES=${d}/1/*
		#echo $SERIES
		for s in ${SERIES[@]}; do
		    if [ -d "$s" ]; then
			convDir=$DEST_DIR/$(basename ${s} .)
			echo "$s -> $convDir"
			if [ ! -d "$convDir" ]; then
			    mkdir $convDir
			fi	       			
			# convert to nifty with dcm2niix
			#echo dcm2niix -o $convDir -f %4s_%p -z y -s y $s		
			#dcm2niix -o $convDir -f %4s_%q_%p -z y -s y $s
			dcm2nii -4 Y -c N -g Y -o $convDir  -p Y $s
		    fi
		done
	    fi
	done
     ;;

    dirName)
        # assume that we are dealing with DICOM data sorted into
	# subdirectories for each series
	SUBJ=${DICOMDIR}/*
	for d in ${SUBJ[@]}; do 
	    if [ -d "$d" ]; then	
		DEST_DIR=$OUTDIR/$(basename ${d} .)
		if [ ! -d "$DEST_DIR" ]; then
		    mkdir $DEST_DIR
		fi	       
		# there is an extra dir under subj we collapse that
		SERIES=${d}/*
		#echo $SERIES
		for s in ${SERIES[@]}; do
		    if [ -d "$s" ]; then
			convDir=$DEST_DIR/$(basename ${s} .)
			fnStem=$(basename ${s} .)
			niiFile=${fnStem,,}
			echo "$s -> $convDir"
			if [ ! -d "$convDir" ]; then
			    mkdir $convDir
			fi	       			
			# convert to nifty with dcm2niix
			echo dcm2niix -o $convDir -f $niiFile -z y -s y $s
			#dcm2niix -o $DEST_DIR -f %4s_%p   -z i -s y -b y  $d
			dcm2niix -o $convDir  -f $niiFile -z y -s y -b y  $s

		    fi
		done
	    fi
	done
     ;;



    p65)
	        # assume that DICOMDIR is a "subject folder" subfolders is ID
	SUBJ=${DICOMDIR}/*
	for d in ${SUBJ[@]}; do 
	    if [ -d "$d" ]; then	
		DEST_DIR=$OUTDIR/$(basename ${d} .)
		mkdir $DEST_DIR
		
		# convert to nifi with dcm2niix
		# -z y == pigz -z i == internal gz
		# pigz cause buffer overflow for some images, but is faster		
		dcm2niix -o $DEST_DIR -f %4s_%p -z i -s y -m y $d
		START=`pwd`
		cd $DEST_DIR
		# ensure that there are no space in the filenames
		find -name "* *" -type f | rename 's/ /_/g'
                # place data into subfolders
		FILES=(*)
		for i in ${FILES[@]}; do 
                    # split filename using "_" as delim
		    FN=(${i//_/ })
		    EXT=${i#*.}
		    DIRNAME=$(basename $i .$EXT)
		    if [ ! -d "$DIRNAME" ]; then
			mkdir "$DIRNAME"
		    fi
		    TEMP=${FN[@]:1}
		    NEW_FN=${TEMP// /_}
		    mv $i $DIRNAME/$NEW_FN
		    #mv $i $DIRNAME/$TEMP
		done
		cd $START
	    fi
	done
       ;;    
    ?)
    echo "Unrecognized mode option\n exiting"
    ;;
 esac
   
    
