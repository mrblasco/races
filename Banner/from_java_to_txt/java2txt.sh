#!/bin/bash

# 
# source_dir="../Submissions/SolutionsSource"
source_dir="testcases"
output_dir="submissions2"
temp_dir="temporary"

# Create output dir
if [ ! -e $output_dir ]; then 
	mkdir $output_dir
fi

# Create temporary dir
mkdir $temp_dir
cp lib/* $temp_dir

# For each submission file:
for f in $source_dir/*
do
    echo "Processing $f"
    filename=`basename $f`
    handle="${filename%-*}"
    if [ ! -e $output_dir/$handle ]; then 
    	mkdir $output_dir/$handle
    fi
    
	cp $f $temp_dir/BannerAnnotate.java     # Rename submission file
	javac $temp_dir/BannerAnnotate.java		# Compile submission file
	java -cp $temp_dir UseBannerAnnotate > $output_dir/$handle/$filename.txt
# 	rm $temp_dir/BannerAnnotate.* 			# Remove program
done

# Errors 
# EgorLakomkin 1-5 (only first 5 submissions are no good)
#Johan.de.Ruiter-1 
# Psyho-1 ## in C++
# ZLATKO 
# al_gol-11
# all_random
#nkshn
# pfr ## in C++
# rado Should work
# neo.subrata-1
# logico14
#klo86min-3
# fujiyama-5
