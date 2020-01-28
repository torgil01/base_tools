#!/bin/bash
# run topup + eddy on dwi data with one PA scan
# 
# processing steps
# 1. topup
# 2. eddy
# 4. dti_fit

function usage {
  echo "DTI processing with FSL topup & eddy"
  echo "Usage:  "
  echo "$0  -i dti_image_stack  -v bvec_file -b bval_file\
        -o base_name_of_dti_output -p b0-pa-file -e echo-spacing"
}

function chkFile () {
    if [ ! -e $1 ]
    then
	echo "Error file $1 is missing"
	exit 2
    fi
}

function doCmd () {
    cmd="$1"
    logging="$2"
    logfile="$3"    
    if [ "$logging" = true ]; then
	echo $cmd  >> $logfile
	echo $cmd  
	eval "$cmd" >> $logfile
	echo "--------------------------------------------------------------"
	echo ""	
    else
	echo $cmd 
	eval "$cmd" 
    fi
}


# test for empty args
if [ $# -eq 0 ] 
    then
      usage
      exit 2
fi

# parse args
while getopts "i:v:b:o:p:e:" flag
do
  case "$flag" in
    i)
	dtiStack=$OPTARG
	;;
    v)
	bvec=$OPTARG
	;;
    b)
	bval=$OPTARG
	;;
    o)
	ostem=$OPTARG	  
	;;
    e)
	es=$OPTARG
	;;
    p)
	b0PA=$OPTARG
	;;
    h|?)
      echo $flag
      usage
      exit 2
      ;;
  esac
done

## main
logging=true
imExt=.nii.gz
initDir=`pwd`
dtiDir=$(dirname "${dtiStack}")
export OMP_NUM_THREADS=7 # 
####################
# test inputs 
####################
chkFile $dtiStack
chkFile $bvec
chkFile $bval
chkFile $b0PA
####################
# set up logfile
####################
if [ "$logging" = true ]; then
    logfile=${dtiDir}/topup_eddy_log.txt
    echo "************************"   >> $logfile 
    date  >> $logfile
    echo "DTI dir = $dtiDir" >> $logfile
    echo "************************"  >> $logfile 
fi

########################################
# Init vars
########################################
dtiStackName=$(basename "${dtiStack}" $imExt)


########################################
# 1. coreg b0_pa -> dti_b0
# topup and eddy corrects for motion between
# scans, but the warp produced by topup
# must be in register with the DTI stack we input
# to eddy. We therefore aling the b0AP scan to the 1st volume
# in the DTI stack (which is also a B0) 
########################################
##apDir=`dirname $b0AP`
paDir=`dirname $b0PA`
dtiDir=`dirname $dtiStack`
omat=${paDir}/PA_to_dti.mat
b0PAco=${paDir}/b0PAcoreg
dtiFirstB0=${dtiDir}/firstB0
cmd="fslroi "$dtiStack" \
	    "$dtiFirstB0" \
	     0 1"
doCmd "$cmd" "$logging" "$logfile"

# the b0-pa scan may be multi-volume
if [[ $(fslnvols $b0PA) > 1 ]]; then
    echo "B0-PA is multivolume; we use the 1st volume"
    fn=$(basename ${b0PA} ${imExt})
    firstPA=${paDir}/firstPA
    cmd="fslroi "$b0PA" \
	    "$firstPA" \
	     0 1"
    doCmd "$cmd" "$logging" "$logfile"
    b0PA=$firstPA${imExt}
fi
# now realign
cmd="flirt -in $b0PA -ref $dtiFirstB0 -out $b0PAco -omat $omat -interp  nearestneighbour "
doCmd "$cmd" "$logging" "$logfile"


########################################
# 2. merge 1st b0 (which is ap) and PA volumes
# the merged stack is input to topup
########################################
p2A=${dtiDir}/b0_ap_pa${imExt}
cmd="fslmerge -t $p2A $dtiFirstB0 $b0PAco "
doCmd "$cmd" "$logging" "$logfile"
aqParams=${dtiDir}/aqparams.txt
printf "0 -1 0 $es\n0 1 0 $es" > $aqParams


########################################
# 3. topup
# Note that b02b0.cnf uses sub-sampling to speed up the estimation and that topup
# requires that the image-size is a multiple of the sub-sampling level. So, for
# example if you want to use sub-sampling by a factor of 2 the image-size should
# be a multiple of 2 in all directions (e.g. 96x96x48).
########################################
topupOut=${dtiDir}/topupOut
topupB0=${dtiDir}/topupB0
cmd="topup --imain=$p2A \
      --datain=$aqParams \
      --config=${FSL_DIR}/etc/flirtsch/b02b0.cnf \
      --out=$topupOut \
      --iout=$topupB0"
doCmd "$cmd" "$logging" "$logfile"

########################################
# 4. create mask from topup b0 output
########################################
fslmaths  "$topupB0" -Tmean "$topupB0"
cmd="bet "$topupB0" ${dtiDir}/topupB0_brain$imExt -m -R -f 0.3"
doCmd "$cmd" "$logging" "$logfile"
brainMask=${dtiDir}/topupB0_brain_mask

########################################
# 5. create index file to eddy
########################################
nVol=`fslnvols $dtiStack`
indexFile=${dtiDir}/index.txt
indx=""
for ((i=1; i<=${nVol}; i+=1)); do indx="$indx 1"; done
echo $indx > $indexFile

sliceSpecFile=${dtiDir}/dwi_slspec.txt
for ((i=2; i<=${nVol}; i+=2)); do echo "$i" >> $sliceSpecFile ; done
for ((i=1; i<=${nVol}; i+=2)); do echo "$i" >> $sliceSpecFile ; done



########################################
# 6. run eddy
########################################
dtiCorrected=${dtiDir}/${ostem}
cmd="eddy_openmp --imain=${dtiStack} \
     --mask=${brainMask} \
     --acqp=${aqParams} \
     --index=${indexFile} \
     --bvecs=${bvec} \
     --bvals=${bval} \
     --cnr_maps \
     --topup=${topupOut} \
     --repol \
     --out=${dtiCorrected}"
doCmd "$cmd" "$logging" "$logfile"


# only when much movement
#  --estimate_move_by_susceptibility \

# need the cuda version for this!
# --mporder=4 \
#      --slspec=$sliceSpecFile \
#      --s2v_niter=5  \
#      --s2v_lambda=1 \
#      --s2v_interp=trilinear \

