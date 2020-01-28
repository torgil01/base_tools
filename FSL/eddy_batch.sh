#!/bin/bash
# batch script for eddy
function chkFile () {
    if [ ! -e $1 ]
    then
	echo "Error file $1 is missing"
	exit 2
    fi
}


dataDir=/home/where_the_data_are
es=0.08 # echo spacing
dtiName=DTI_2mm_iso  # basename name of dti image stack without .nii.gz
paName=b0_PA.nii.gz

# loop over subjects in dataDir
subjDirs=$(find $dataDir -maxdepth 1 -mindepth 1 -type d)

for id in ${subjDirs[@]}; do
    echo "working on id = $id"        
    # find dti image
    dti=$(find $id -name ${dtiName}.nii.gz)
    if [ -e $dti ]; then
	echo "eddy on dti"
	bvec=$(find $id -name ${dtiName}.bvec)
	bval=$(find $id -name ${dtiName}.bval)
	b0PA=$(find $id -name ${paName})
	dtiDir=$(dirname $dti)
	bash run_eddy.sh -i $dti -v $bvec -b $bval -o $dtiCorrName -e $es -p $b0PA
    fi    
done
