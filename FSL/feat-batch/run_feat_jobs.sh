#!/bin/bash

IMDIR=/home/torgil/Projects/Anorexia/3T/test


jobFiles=(`find $IMDIR -name \*.fsf -type f`)
for jobFile in ${jobFiles[@]}; do
    feat $jobFile

done
