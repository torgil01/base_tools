* mask_for_ARBM.nii is the mniMask file to be used in "ARBM.m"
It is a manual segmentation of the intracranial volume of the MNI-T1 template 

*brainMask_dartel.nii is the ICV brain mask for the RBM method. It is the sum of the three tissutypes in the Dartel TPM file 


ImageMath 3 dil.nii.gz MD mask_for_ARBM.nii.gz 20 
