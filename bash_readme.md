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
For-loops are ideal for doing the same operation on a list of items. 

```bash
# simple loop from list
for i in {0..3}
do
  echo "Number: $i"
done


# loop four times 
for ((a=1; a <= 5 ; a++))
do
   echo $a
done


# loop over elements in array. Note the way the array is expanded
files=(a b c d)
for f in ${files[@]} 
do
    echo $f
done
```

### If statements
If statemenst are used to test for some logical test. In bash you write a logical test in square brackets : `[ logical test ]`. We say *logical test* since the statement inside the brackets can only be *true* pr *false*. If statemenst are useful for branching your code. Say if your script will crash if some file does not exist. Then it is useful to add a *if-statement* to check the existence of the file beforehand.   


```bash
# Basic if statement
if [ $1 -gt 100 ]
then
    echo "$1 is greater than 100"
fi


```



