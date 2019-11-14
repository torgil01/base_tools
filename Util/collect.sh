#!/bin/bash

# TARGETS=(T1_MPRAGE.nii.gz \
# 	     t1mprageadniipat2.nii.gz \
# 	     T1MPRAGE.nii.gz \
# 	     t1mprageadniipat2_def.nii.gz \
# 	     T1-MPRAGE.nii.gz \
# 	     WIP_T1_3D_SENSE.nii.gz)
# SUBDIR=T1
# FNAME=t1w.nii.gz

# for fmri 
TARGETS=(rsfmri.nii.gz \
	     RS-FMRI.nii.gz \
	     RSFMRI.nii.gz
	     fmristd.nii.gz \
	     WIP_RESTING_STATE_SENSE.nii.gz)

SUBDIR=FMRI
FNAME=fmri.nii.gz



STUDY_DIR="/home/torgil/Nshare/Anoreksi_Per/nii"
destDir=/home/torgil/Projects/Anorexia/3T/img

# loop over study dir and find target
subjDirs=(`find $STUDY_DIR -maxdepth 1 -mindepth 1 -type d`)
for d in ${subjDirs[@]}; do
    id=`basename "$d"`	
    for t in ${TARGETS[@]}; do
	target=`find "$d" -type f -name "$t"`
	if [[ -n $target ]]; then	    
	    fn=`basename $target`
	    if [ ! -e ${destDir}/${id} ]; then
	       mkdir ${destDir}/${id}
	    fi
	    if [ ! -e ${destDir}/${id}/${SUBDIR} ]; then	       
		mkdir ${destDir}/${id}/${SUBDIR}
	    fi
       	    # actual copy
	    if [ ! -f ${destDir}/${id}/${SUBDIR}/${FNAME} ]; then	       
		cp $target ${destDir}/${id}/${SUBDIR}/${FNAME}
	    fi	    
	    # found target exiting current loop
	    break
	fi
    done
done

