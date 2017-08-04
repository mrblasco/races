#!/bin/bash

#****************************************#
# FUNCTIONS
#****************************************#
compile_notebook () {
	Rscript -e "rmarkdown::render('Notebook/_note.Rmd')"
	#	open Notebook/_note.html
	#	open -a Skim Notebook/_note.pdf
}
compile_paper () {
	Rscript -e "rmarkdown::render('Paper/report.Rmd')" 
	open Paper/report.pdf
}
compile_slides () {
	Rscript -e "rmarkdown::render('Slides/slides.Rmd')"
	open -a Skim Slides/slides.pdf
}
open_files () {
	open -a TextWrangler Notebook/*.Rmd
}
prepare_data () {
	cd Data_prep
	rm -r races_old
	Rscript package_creation.R
}
display_help () {
	echo "Usage:"
	echo "\t-d : prepare data"
	echo "\t-h : display help"
	echo "\t-n : compile Notebook"
	echo "\t-o : open all source files"
	echo "\t-p : compile Paper"
	echo "\t-s : compile Slides"
	exit 1
}
#****************************************#

if [ -z "$1" ]; then 
	display_help
fi

while getopts ":dhnops" opt; do
  case $opt in  
    d)
		prepare_data
		;;
    h)
		display_help
		;;
    n)
		compile_notebook
		;;
    o)
		open_files
		;;
    p)
		compile_paper
		;;
    s)
		compile_slides
		;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done
shift $((OPTIND-1))
