#!/bin/bash 
# unzip zip files in current directory
files=(*.zip)
for file in "${files[@]}"; do
   newDir=$(basename "$file" ".zip") #rm ext for zip file and use as new dir
   if [ ! -d "$newDir" ]
   then
       #echo $newDir
       unzip  $file -d $newDir
       # maybe a flag for this?
       #rm $file
   else
       echo "Warning directory exists, skipping"
   fi
done
