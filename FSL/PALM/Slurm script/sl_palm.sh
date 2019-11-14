#!/bin/bash

#####################
# submit randomise job
#####################
#SBATCH --account=uit-med-001
#SBATCH --job-name=palm
#SBATCH --time=0-04:00:00
#SBATCH --partition=singlenode
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=31GB
# ---------------------------------------------
# you may not place bash commands before the last SBATCH directive
#PALM
PALM=/home/torgil/Software/PALM/palm
# matlab
module load MATLAB/R2016a-intel-2016a
# fsl
module load FSL/5.0.9-intel-2016a-Mesa-11.2.1
# set up FSL, 
FSLDIR=/global/hds/software/cpu/eb3/FSL/5.0.9-intel-2016a-Mesa-11.2.1/fsl/
source ${FSLDIR}/etc/fslconf/fsl.sh
export FSLOUTPUTTYPE=NIFTI_GZ
# parse args
while getopts "hi:o:m:d:t:D" flag
do
  case "$flag" in
      i)
	DATA=$(readlink -f  "$OPTARG")
      ;;
      o)
	OUT=$(readlink -f "$OPTARG")
	;;
      m)
	  MASK=$(readlink -f "$OPTARG")
	  ;;
      d)
	  DESIGN=$(readlink -f "$OPTARG")
	  ;;
      t)
	  CON=$(readlink -f "$OPTARG")
	  ;;
      D) 
	  DMEAN=TRUE
	  ;;
      h|?)    
      echo Unknown input flag $flag
      exit 2
      ;;
  esac
done

# defalts for randomise
ITER=500
# define and create a unique scratch directory 
SCRATCH_DIRECTORY=/global/work/${USER}/palm_${SLURM_JOBID}
mkdir -p ${SCRATCH_DIRECTORY}
cd ${SCRATCH_DIRECTORY}

# todo chk fsl_ext param
outName=$(basename "$OUT")
outDir=$(dirname "$OUT")
echo "OutDir = $outDir"
logFile=${outName}.log
tmpOUT=${SCRATCH_DIRECTORY}/${outName}
tmpDATA=${SCRATCH_DIRECTORY}/data.nii.gz
tmpMASK=${SCRATCH_DIRECTORY}/mask.nii.gz
cp $DATA $tmpDATA
cp $MASK $tmpMASK
gunzip $tmpDATA
gunzip $tmpMASK
tmpDATA=${SCRATCH_DIRECTORY}/data.nii
tmpMASK=${SCRATCH_DIRECTORY}/mask.nii

# run PALM

if [ -z $DMEAN ]; then 
    $PALM -i $tmpDATA \
        -d $DESIGN \
        -t $CON \
        -m $tmpMASK \
        -T \
        -C 3.1 \
	-accel tail \
	-nouncorrected \
        -n $ITER \
        -logp \
	-rmethod Manly \
        -o $tmpOUT  > $logFile
else
    $PALM -i $tmpDATA \
        -d $DESIGN \
        -t $CON \
        -m $tmpMASK \
        -T \
        -C 3.1 \
	-accel tail \
	-nouncorrected \
        -demean \
        -n $ITER \
        -logp \
	-rmethod Manly \
        -o $tmpOUT  > $logFile
fi

# note 
# 	-rmethod Manly \ for reducing memory
# consider also 	-rmethod Draper-Stoneman

# afther the job is done we copy our output to dest
cp ${outName}* ${outDir}/.
cp ${logFile}  ${outDir}/.

# we step out of the scratch directory and remove it
cd ${SLURM_SUBMIT_DIR}
rm -rf ${SCRATCH_DIRECTORY}

# happy end
exit 0

