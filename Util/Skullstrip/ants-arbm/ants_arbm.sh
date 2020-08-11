#!/bin/bash
# arbm method with ants
# NOTE! the input images benefit from N4 bias correction before skull strip
# Usage
# ants_arbm.sh -i t1-file -d studyDir -m brain_mask_name
# T1NAME=mp2rage_corrected.nii
# SDIR=/home/torgil/Projects/WMH-PET/Testing/mp2rage_skullstrip/Data/test2/
# brainMaskName=brainmask.nii.gz

# parse inputs 
#
# test for empty args
if [ $# -eq 0 ] 
    then
      usage
      exit 2
fi


# delete temp files?
cleanup=TRUE
# parse args

while getopts "i:d:m:" flag
do
  case "$flag" in
    i)
      T1NAME=$OPTARG
      ;;
    d)
      SDIR=$OPTARG
      ;;
    m)
      brainMaskName=$OPTARG
      ;;
    h|?)
      echo $flag
      usage
      exit 2
      ;;
  esac
done
# get path
CODE=$(dirname $(readlink -f $0))
TEMPLATE=$FSL_DIR/data/standard/MNI152_T1_1mm.nii.gz
TEMPLATE_BRAIN=$FSL_DIR/data/standard/MNI152_T1_1mm_brain.nii.gz
TEMPLATE_HUNT=${CODE}/templates/N32-T1-template.nii.gz
#TMASK=${CODE}/templates/mask_for_ARBM.nii.gz
TMASK=${CODE}/templates/new_arbm_mask.nii.gz
templMask=${CODE}/templates/dil_20.nii.gz
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=5


# compute template -> T1 transform
# loop over study dir and find target
T1Files=$(find $SDIR -name $T1NAME -type f)

for MOVING in ${T1Files[@]}; do    
    imDir=$(dirname $MOVING)
    OUT=${imDir}/t1_to_template_quick
    # calculate native -> MNI warp
    antsRegistrationSyNQuick.sh -d 3\
     				-n $ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS \
     				-j 0 \
     				-f $TEMPLATE \
     				-m $MOVING \
     				-t s \
     				-o $OUT    


    # warp MNI -> native 
    flMask=${imDir}/floatMask.nii.gz   
    antsApplyTransforms -d 3\
			-i $TMASK \
			-r $MOVING \
			-o $flMask \
			-t [${OUT}0GenericAffine.mat,1] \
    			-t ${OUT}1InverseWarp.nii.gz \
			-n Linear

    # name of binary brainmask
    brainMask=${imDir}/${brainMaskName}
    fslmaths $flMask -thr 0.1 -bin $brainMask
    
    # mask brain
    ssBrain=${imDir}/t1w_brain_0.nii.gz
    fslmaths $MOVING -mul $brainMask  $ssBrain

    # now run a more accurate mni_brain -> native_brain transform
    warpName=${imDir}/t1_to_template
    moving=$ssBrain
    target=$TEMPLATE_HUNT
    antsRegistration --verbose 1\
		 --dimensionality 3\
		 --float 0\
		 --masks [$brainMask,$templMask] \
 		 --output [${warpName},${warpName}Warped.nii.gz,${warpName}InverseWarped.nii.gz]\
		 --interpolation Linear\
		 --use-histogram-matching 0\
		 --winsorize-image-intensities [0.005,0.995]\
		 --initial-moving-transform [${target},${moving},1]\
		 --transform Rigid[0.1]\
		 --metric MI[${target},${moving},1,32,Regular,0.25]\
		 --convergence [1000x500x250x10,1e-6,10]\
		 --shrink-factors 8x4x2x1\
		 --smoothing-sigmas 3x2x1x0vox\
		 --transform Affine[0.1]\
		 --metric MI[${target},${moving},1,32,Regular,0.25]\
		 --convergence [1000x500x250x10,1e-6,10]\
		 --shrink-factors 8x4x2x1\
		 --smoothing-sigmas 3x2x1x0vox\
		 --transform SyN[0.1,3,0]\
		 --metric CC[${target},${moving},1,4]\
		 --convergence [100x70x50x10,1e-6,10]\
		 --shrink-factors 8x4x2x1\
		 --smoothing-sigmas 3x2x1x0vox


     antsApplyTransforms -d 3\
			-i $TMASK \
			-r $MOVING \
			-o $brainMask \
			-t [${warpName}0GenericAffine.mat,1] \
    			-t ${warpName}1InverseWarp.nii.gz \
			-n Linear

     # correct boundary of mask
     fslmaths $brainMask -thr 0.5 -bin $brainMask

     
     t1Brain=${imDir}/t1w_brain.nii.gz
     fslmaths $MOVING -mul $brainMask  $t1Brain


     if [ $cleanup == TRUE ]; then
	 rm $ssBrain $flMask ${imDir}/t1_to_template_quick*
     fi
     
done
