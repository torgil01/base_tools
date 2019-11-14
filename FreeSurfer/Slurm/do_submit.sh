
idList=(0235 0011  0027  0035  0048  0056  0084  0137  0141  0162  0178  0188  0195  0221  0238)

for id in ${idList[@]}; do
   sbatch sl_freesurfer.sh -i source/${id}/t1.nii.gz -p SubjectsDir -o ${id}
done

