imDir=/home/torgil/Projects/HUNT/WorkData
imName=brain_t1w.nii.gz
bash getMaskData.sh $imName $imDir

#
imName=logJac_native.nii.gz
bash getMaskData.sh $imName $imDir

#
imName=wFA_t1.nii.gz
bash getMaskData.sh $imName $imDir

#
imName=wMD_t1.nii.gz
bash getMaskData.sh $imName $imDir


