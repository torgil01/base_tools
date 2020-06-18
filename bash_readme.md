# Bash readme

## Variables 

Declare variable. 

```bash
# Note, no spaces
file=readme.text
echo $file

# declare string
message="hello there"
echo $message

# declare array
files=(0004_FA.nii.gz \
  0009_FA.nii.gz \
  0010_FA.nii.gz \
  0061_FA.nii.gz \
  0063_FA.nii.gz \
  0067_FA.nii.gz)

for f in ${files[@]}; do
    echo $f
done
```
## Control structures

### For loops

```bash
files=(a b c d)
for f in ${files[@]}; do
    echo $f
done
```

### If statements






