#!/bin/bash
# Andrea Blasco <ablasco@fas.harvard.edu>
#***********************************************#
E_BADDIR=85 # Error bad directory
E_BADFILE=86 # Error bad file

input_file=$1

if [ ! -f "$input_file" ] # Check input file
then
	echo "$input_file file not found!"
	exit $E_BADFILE
fi	

#***********************************************#
bib_file="$HOME/Library/Application Support/BibDesk/library.bib"
config_dir="Config"
output_dir="$2"
#***********************************************#

if [ ! -d "$output_dir" ] || [ ! -d "$config_dir" ] # Check
then
	echo "$output_dir or $config_dir is not a directory."
	exit $E_BADDIR
fi

# --------------------------------------------------------- #
# copy_data ()                                         		#
# Copy all files in designated directory.                	#
# Parameters: $target_directory, $config_dir                #
# Returns: 0 on success, $E_BADDIR if something went wrong. #
# --------------------------------------------------------- #
copy_data () {
	cp -v "$bib_file" "$1"
	cp -v .RData "$1"
	cp -vR "$2"/* "$1"
	cp -v *.Rmd "$1"
	cp -v *.R "$1"
	return 0
}
clean_dir () {
	rm -r "$1"/*
	return 0
}

# Compile report
clean_dir $output_dir
copy_data $output_dir $config_dir
cd $output_dir
Rscript -e "rmarkdown::render('$input_file')"
mkdir Code && mv *.Rmd Code

# Open document
open -a Skim ${input_file%.*}.pdf

exit 0