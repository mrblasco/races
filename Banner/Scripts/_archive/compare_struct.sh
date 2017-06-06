#!/bin/bash

xmlstarlet el -u $1 | sort > 3.xml
var=`diff 2.xml 3.xml`
#echo $var
if [ ! -z "$var"  ]; then
    echo "input file struct not correct"
fi
cp $1 new_training.xml
cp $2 new_testing.xml
