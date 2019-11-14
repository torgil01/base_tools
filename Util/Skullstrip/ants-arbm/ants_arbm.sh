#!/bin/bash

# arbm method with ants

T1NAME=t1w.nii.gz
TEMPLATE=/home/torgil/Git/Util/Skullstrip/arbm/templates/MNI152_T1_1mm.nii.gz
TMASK=/home/torgil/Git/Util/Skullstrip/ants-arbm/templates/mask_for_ARBM.nii.gz
DMASK=/home/torgil/Git/Util/Skullstrip/ants-arbm/templates/dil_20.nii.gz
ncores=12
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$ncores
SDIR=/home/torgil/Projects/Anorexia/3T/img/
brainMaskName=brainmask.nii.gz

# compute template -> T1 transform
# loop over study dir and find target
T1Files=(`find $SDIR -name $T1NAME -type f`)
for MOVING in ${T1Files[@]}; do    
    imDir=$(dirname $MOVING)
    OUT=${imDir}/t1_to_template

    antsRegistrationSyN.sh -d 3\
    				-n $ncores \
    				-j 1 \
    				-f $TEMPLATE \
    				-m $MOVING \
				-x $DMASK \
    				-o $OUT
    
    # warp wmh 
    antsApplyTransforms -d 3\
			-i $TMASK\
			-r $MOVING\
			-o ${imDir}/${brainMaskName}\
			-t [${OUT}0GenericAffine.mat,1]\
    			-t ${OUT}1InverseWarp.nii.gz\
			-n NearestNeighbor
    
    # mask brain		     
    fslmaths $MOVING -mul ${imDir}/${brainMaskName}  ${imDir}/t1w_brain.nii.gz
done


# code for using masks , however, this does not work with current binary release
# need to compile code

    # movingMask=${imDir}/bm.nii.gz
    # tmp1=${imDir}/tmp1.nii.gz
    # tmp2=${imDir}/tmp2.nii.gz
    # echo "***** mri_watershed ********"
    # mri_watershed $MOVING $tmp1
    # echo "*****  bet ********"
    # bet $tmp1 $tmp2 -f 0.2 -m # prduce mask file tmp2_mask.nii.gz
    # betMask=${imDir}/tmp2_mask.nii.gz
    # movingMask=${imDir}/brainmaskDil20.nii.gz
    # echo "*****  ImageMath ********"
    # ImageMath 3 $movingMask MD $betMask  20
    # rm $tmp1 $tmp2 $betMask



    # antsRegistration --verbose 1\
    # 		     --dimensionality 3\
    # 		     --float 0\
    #                  --output [${OUT},${OUT}Warped.nii.gz,${OUT}InverseWarped.nii.gz]\
    # 		     --interpolation Linear\
    # 		     --use-histogram-matching 1\
    # 		     --winsorize-image-intensities [0.005,0.995]\
    # 		     --initial-moving-transform ["$TEMPLATE","$MOVING",1]\
    # 		     --transform Rigid[0.1]\
    # 		     --masks [NULL,NULL]\
    # 		     --metric MI["$TEMPLATE","$MOVING",1,32,Regular,0.25]\
    # 		     --convergence [1000x500x250x100,1e-6,10]\
    # 		     --shrink-factors 8x4x2x1\
    # 		     --smoothing-sigmas 3x2x1x0vox\
    # 		     --transform Affine[0.1]\
    # 		     --masks [NULL,NULL]\
    #                  --metric MI["$TEMPLATE","$MOVING",1,32,Regular,0.25]\
    # 		     --convergence [1000x500x250x100,1e-6,10]\
    # 		     --shrink-factors 8x4x2x1\
    # 		     --smoothing-sigmas 3x2x1x0vox\
    # 		     --transform SyN[0.1,3,0]\
    # 		     --masks [$fixedMask,$movingMask]\
    # 		     --metric CC["$TEMPLATE","$MOVING",1,4]\
    # 		     --convergence [100x70x50x20,1e-6,10]\
    # 		     --shrink-factors 8x4x2x1

