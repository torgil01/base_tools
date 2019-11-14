#!/bin/bash 
# zip subdirectories in current directory
files=(*)
for file in "${files[@]}"; do
    if [ -d "$file" ]
    then 
	zip -r $file $file
	rm -r $file
    fi
done
