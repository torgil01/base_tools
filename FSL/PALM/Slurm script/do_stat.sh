#!/bin/bash

DATA=/home/torgil/Projects/HUNT/data15/jac_s2.nii.gz
MASK=/home/torgil/Projects/HUNT/data15/brainmask_15.nii.gz
GLMDIR=/home/torgil/Projects/HUNT/glm/

sbatch sl_palm.sh -i $DATA  -o ${OUT}/jac_2tt_C2  -m $MASK -d $MAT -t $CON
