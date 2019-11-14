#!/bin/bash

# crop 4D volumes that have more than MAXVOL volumes

IMDIR=/home/torgil/Projects/Anorexia/3T/img
FMRI=fmri.nii.gz
MAXVOL=288

# loop over study dir and find target
fmriFiles=(`find $IMDIR -name $FMRI -type f`)
for thisFile in ${fmriFiles[@]}; do
    nv=$(fslnvols $thisFile)
    if [ "$nv" -gt "$MAXVOL" ]; then
	echo "File is $nv volumes, cropping to $MAXVOL volumes"
	tempfile=$(mktemp -t ffXXXX.nii.gz)
	fslroi $thisFile  $tempfile 0 $MAXVOL
	rm $thisFile
	mv $tempfile $thisFile
    fi
    
    
done
