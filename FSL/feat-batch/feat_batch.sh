#!/bin/bash


IMDIR=/home/torgil/Projects/Anorexia/3T/test
FMRI=fmri.nii.gz
featTemplate=/home/torgil/Projects/Anorexia/3T/feat-batch/fj.fsf
FEATOUT=/home/torgil/Projects/Anorexia/3T/feat-out/
T1NAME=t1w_brain

# constants
TR=2.5
NPTS=288
TE=30 
FWHM=8
stdBrain=/usr/share/fsl/5.0/data/standard/MNI152_T1_2mm_brain


# loop over study dir and find target
fmriFiles=(`find $IMDIR -name $FMRI -type f`)
for thisFile in ${fmriFiles[@]}; do
    fmriDir=$(dirname $thisFile)
    subjDir=$(dirname $fmriDir)
    id=$(basename $subjDir)
    # copy feat job tempate to subjDir
    featJob=${subjDir}/${id}_feat.fsf
    cp $featTemplate $featJob

    
    # insert output dir
    outDir=${FEATOUT}/${id}
    sed -i "s|#outputdir#|$outDir|g" $featJob        
    # insert TR
    sed -i "s/#tr#/$TR/g" $featJob
    # insert NPTS
    sed -i "s/#npts#/$NPTS/g" $featJob
    # insert TE
    sed -i "s/#te#/$TE/g" $featJob
    # slice timing file
    # decide which slice timing file to use
    nslices=$(fslval $thisFile dim3)
    nslices_s=$(echo $nslices)
    case "$nslices_s" in
	39)
	    sliceOrderFile=/home/torgil/Projects/Anorexia/3T/feat-batch/slicetiming_skyra39.txt
	    ;;
	43)
	    sliceOrderFile=/home/torgil/Projects/Anorexia/3T/feat-batch/slicetiming_skyra43.txt
	    ;;
	45)
	    sliceOrderFile=/home/torgil/Projects/Anorexia/3T/feat-batch/slicetiming_philips.txt
	    ;;
	*)
	echo "number of slices = $nslices"
	exit 2
    esac
    echo $id $nslices $sliceOrderFile
   sed -i "s|#sliceOrderFile#|$sliceOrderFile|g" $featJob
   
    # insert FWHM smooth
    sed -i "s/#fwhm#/$FWHM/g" $featJob
    # insert ref brain
    # avoid issue with / in path by using different separator in sed
    sed -i "s|#regstandard#|$stdBrain|g" $featJob

    # insert total voxels
    tv=$(($(fslval $thisFile dim1) * $(fslval $thisFile dim2) * $(fslval $thisFile dim3) * $(fslval $thisFile dim4) ))
    sed -i "s/#totalVoxels#/$tv/g" $featJob

    # insert fmri file
    sed -i "s|#fmriFile#|$thisFile|g" $featJob

    # insert t1_brain file
    t1w=${subjDir}/T1/$T1NAME
    sed -i "s|#t1w#|$t1w|g" $featJob

done




