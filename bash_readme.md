# Bash readme

Quickguide to BASH.

There are also several guides on the web: 

* __Reference guide:__ https://www.gnu.org/software/bash/manual/html_node/index.html#Top
* __Nice introduction to bash:__ https://github.com/Idnan/bash-guide
* __A cheatsheet:__ https://devhints.io/bash



## Running bash scripts
There are several ways to run a bash script. Say you have a script called `test.sh`. (Note that you can call it anything you want, 
but it is a good idea to let the file end with `*.sh` so you know that it is a bash script.  

1. set the file to be executable: write `chmod u+x test.sh`. You can then run the script by typing `./test.sh`.
2. run the script by typing `bash test.sh` 
3. make the file executable and place the script in a *scripts* folder. If you add a folder to your `PATH` variable, you can run the run the script anywhere, by just typing `test.sh`


## Variables 

## Built-in variables 
Bash has several predefined variables, and other variables defined at runtime.

* $HOME : this is the path to your "home directory" 


Declare variable. 
You declare (ie. set the value) a variable by typing `variable_name=value`. Note no speces around the equal sign. When you want to use the variable you have to set a `$`-sign in front of the variable name. Ie. `echo $variable_name`.


```bash
# Note, no spaces
file=readme.text
echo $file

# declare string, note the quotation marks around the text.
message="hello there"
echo $message

# declare array, just leave a space between each element
files=(0004_FA 0009_FA 0010_FA 0061_FA) 

# now print all elemnts 
for f in ${files[@]}; do
    echo $f
done
``` 

### Variables from input arguments
It is easy to read input arguments to a script. For example if you run a script `add.sh` with two input arguments "2" and "4", this would be `add.sh 2 4`. You can access the input via the `$1`and `$2` variables, and if you had more input argumenst there would be a `$3` and `$4` etc. 

Try the script below to see how this works. Also note that `$0` is the name of the script.

```bash
# add.sh
# add two numbers
answ=$(( $1 + $2 ))
echo "$1 + $2 = $answ"
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

Some useful logical tests:

```bash

# test if file exist, ie. if it the file exist the test below is TRUE
[[ -e $name ]]

# you can use the not operator "!" to do the inverse operation 
# the statement below will evaluate to TRUE if the file does not exist
[[ ! -e $name ]]

# test if directory exist
[[ -d $name ]]

# test if variable is empty 
[ -z $name ]

```

# Useful commands

## find 
The find command can find files or directories based on certain criteria. 

*Examples*
```bash 

# find files in the present directory and any subdirectories that ends with `.gz`. 
find . -type f -name "*.gz"

# find files in $work_dir directory and subdirectories that ends with `.gz`. 
work_dir=${HOME}/Documents
find $work_dir -type f -name "*.gz"

# assign results from find to variable, in the command below all files ending with `*.gz` will be listed in the `$gz_files` variable. Note that if there are no hits,  `$gz_files`  will be empty. 
gz_files=$(find $work_dir -type f -name "*.gz")

# print only filename 
find . -name xxx -printf "%f\n"
```
 
## basename and dirname
`basename` and `dirname` are handy when manipulating file and directory paths. 

Some typical uses: 

```bash

file=/home/user/work/test.dat

# just get the filename not the whole path
filename=$(basename $file)
echo $filename
> test.dat

# get the filename omitting the extension (eg .dat)
filename=$(basename $file .dat)
echo $filename
> test

# the the name of the directory where a file is 
dir=$(dirname $file)
echo $dir
> /home/user/work
```


# Troubleshooting
Sometimes the scripts does not work, typically due to some typing mistake. To find the error it helps to read the error message (if any) carefully in order to locate the error. You can also run the script in *debug mode* which should show you the line where the error is. Another option is to print variable names and other diagnostics in the script. 






