#!/bin/bash

# Extract average intensities from aseg ROIs
# we use following labels
# 10 Left-Thalamus-Proper 
# 11 Left-Caudate 
# 12 Left-Putamen 
# 49 Right-Thalamus-Proper 
# 50 Right-Caudate 
# 51 Right-Putamen 



imName=$1
studyDir=$2
##########
labelFile=fsAseg.nii.gz
labels=(10 11 12 49 50 51)
labelNames=("left_thal" "left_cau" "left_put" "right_thal" "right_cau" "right_put")
imSource=$(remove_ext $imName)


i=0
for label in ${labels[@]}; do
    echo "Processing label # $label"
    # step 1 mk masks
    maskOut="roi-${labelNames[$i]}.nii.gz"
    #echo $maskOut
    mkAsegMask.sh -i $studyDir -a $labelFile -m $maskOut -l $label
    # step 2 extract data
    logFile=roi-${labelNames[$i]}-${imSource}.txt
    getMaskval.sh -i $studyDir  -f $imName -m "$maskOut"  >> $logFile
    i=$((i+1))
done
