#!/bin/bash
# Wrapper for "fsl_motion_outliers" script


IMDIR=/home/torgil/Projects/Anorexia/3T/img
FMRI=fmri.nii.gz
MAXVOL=288
FDNAME=motion-FD.txt

# loop over study dir and find target
fmriFiles=(`find $IMDIR -name $FMRI -type f`)
for thisFile in ${fmriFiles[@]}; do
    imDir=$(dirname $thisFile)
    FD=${imDir}/${FDNAME}
    fsl_motion_outliers -i $thisFile -o ${imDir}/confounders -s $FD --fd
    # add id on top of FD file
    tmp=$(dirname $imDir)
    id=$(basename $tmp)
    sed -i "1s/^/$id\n/" $FD
done

# merge FD files

fdFiles=(`find $IMDIR -name $FDNAME -type f`)
pr -mts"," --width=400 ${fdFiles[*]} > fd.csv
