#!/bin/bash
# fix t1 header issues


IMDIR=/home/torgil/Projects/Anorexia/3T/img
T1=t1w.nii.gz
T1b=t1w_brain.nii.gz


subjDirs=(A101R2_20150826 \
	 102_20160201 \
	 103_20160201 \
	 A104_20160411 \
	 A106_20150203 \
	 A107_20150203 \
	 A108_20150203 \
	 A110_20150701 \
	 A111_20150914 \
	 A201_20150617 \
	 A204_20150907 \
	 A205_20150701 \
	 A206_20150617 \
	 A207_20150701 \
	 A209_20150701 \
	 A210_20150907)    

for thisSubj in ${subjDirs[@]}; do
    t1File=${IMDIR}/${thisSubj}/T1/${T1}
    t1_brainFile=${IMDIR}/${thisSubj}/T1/${T1b}    
    # reorient t1
    echo "reorienting $thisSubj"
    fslreorient2std $t1File $t1File
    # reorient t1_brain
    fslreorient2std $t1_brainFile $t1_brainFile
done

