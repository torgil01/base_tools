#!/bin/bash

#####################
# submit freesurfer jobs
#####################
#SBATCH --account=uit-med-001
#SBATCH --job-name=freesurfer
#SBATCH --time=48:00:00
#SBATCH --partition=singlenode
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=6GB
# ---------------------------------------------
# you may not place bash commands before the last SBATCH directive
# FS module
module load FreeSurfer/5.3.0-intel-2016a-centos6_x86_64-loc

# set up freesurfer (freesurfer home set by module)
source $FREESURFER_HOME/SetUpFreeSurfer.sh
SUBJECTS_DIR=/home/torgil/Projects/Freesurfer_subjects_dir

# parse args
while getopts "hi:o:p:" flag
do
  case "$flag" in
      i)
	  # t1w input volume
	  t1w=$(readlink -f  "$OPTARG")
      ;;
      o)
	  # id for current input
	  id=$OPTARG
	;;
      p) 
	  # destination dir for FS output
	  OUTDIR=$(readlink -f  "$OPTARG")
	  ;;
      h|?)    
      echo Unknown input flag $flag
      exit 2
      ;;
  esac
done

# define and create a unique scratch directory 
SCRATCH_DIRECTORY=/global/work/${USER}/FS_${SLURM_JOBID}
mkdir -p ${SCRATCH_DIRECTORY}
cd ${SCRATCH_DIRECTORY}

# todo chk fsl_ext param
logFile=${outName}.log

recon-all -i $t1w -all -subjid $id -sd ${SCRATCH_DIRECTORY}

# mv FS data dir to dest
cp -r $id ${OUTDIR}/.

# we step out of the scratch directory and remove it
cd ${SLURM_SUBMIT_DIR}
rm -rf ${SCRATCH_DIRECTORY}

# happy end
exit 0

