# Bash readme
There are several ways to run a bash script. Say you have a script called `test.sh`. (Note that you can call it anything you want, 
but it is a good idea to call the file `*.sh` so you know that it is a bash script.  

(1) set the file to be executable: write `chmod u+x test.sh`. You can then run the file by typing `./test.sh`.
(2) run the script by typing `bash test.sh`



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






