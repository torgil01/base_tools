#/bin/bash
# It is handy to have all scripts in the local bin folder

#scr=$(find . -name *.sh)

find . -name *.sh -exec cp {} ~/bin \;

