#!/bin/bash
# Wrapper for "fsl_motion_outliers" script


IMDIR=/home/torgil/Projects/Anorexia/3T/img
FMRI=fmri.nii.gz

# loop over study dir and find target
fmriFiles=(`find $IMDIR -name $FMRI -type f`)
for thisFile in ${fmriFiles[@]}; do
    imDir=$(dirname $thisFile)
    tmp=$(dirname $imDir)
    id=$(basename $tmp)
    slice=$(fslval $thisFile dim3)
    des=$(fslval $thisFile descrip)
    px1=$(fslval $thisFile pixdim1)
    px2=$(fslval $thisFile pixdim2)
    px3=$(fslval $thisFile pixdim3)
    
    printf "%s,\t %s,\t %s,\t %s,\t %s,\t %s,\n" "$id" "$px1" "$px2" "$px3" "$slice" "$des"
done

