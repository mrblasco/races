#!/bin/bash
command=${1:---report}

################
# Settings
################
now=`date +%b%d`
paper_dir="Paper"
paper_appendix="Appendix"
paper_notes="Paper_notes"
config_dir="Config"
bib_file="$HOME/Library/Application Support/BibDesk/library.bib"

################
# Commands
################
if [ "$command" == "--report" ]; then
	cp -R "$bib_file" *.Rmd *.R .RData $config_dir/* "$paper_dir"
	cd "$paper_dir" && Rscript -e "rmarkdown::render('report.Rmd')" || exit -1
	mv *.Rmd *.R Code/
	exit 0
fi

if [ "$command" == "--notes" ]; then
	input=report_notes.Rmd
	cp -R "$bib_file" *.Rmd $config_dir/* "$paper_notes"
	cd "$paper_notes" && Rscript -e "rmarkdown::render('$input')" || exit -1
	exit 0
fi

if [ "$command" == "--data" ]; then
	cp .RData $now.RData
	Rscript prep_data.R
	exit 0
fi

# if [ "$1" == "--docx" ]; then
#   echo "Compiling docx..."
#   cp $config_dir/_output_docx.yml $paper_docx_dir/_output.yml
#   compile $paper_docx_dir
#   
# elif [ "$1" == "--html" ]; then
#   echo "Compiling html..."
#   cp $config_dir/_output_html.yml $paper_html_dir/_output.yml
#   cp $config_dir/*.py $paper_html_dir
#   compile $paper_html_dir
# 
# elif [ "$1" == "--all" ]; then
#   echo "Compiling all formats..."
#   cp $config_dir/_output.yml $paper_dir 
#   cp $config_dir/*.py $paper_dir
#   cp $config_dir/_output_docx.yml $paper_docx_dir/_output.yml
#   cp $config_dir/_output_html.yml $paper_html_dir/_output.yml
#   compile $paper_dir && pwd && compile $paper_docx_dir && compile $paper_html_dir
# 
# elif  [ "$1" == "--structural" ]; then
# 	echo "Compiling structural..."
# 	mkdir -p $struct_dir/{Code,Templates}
# 	echo "Copy templates, headers, footers..."
# 	cp Templates/* $struct_dir/Templates
# 	echo "Copy config files..."
# 	cp $config_dir/_output.yml $struct_dir
# 	echo "Copy main file..."
# 	cp structural.Rmd $struct_dir
# 	echo "Compile structural..."
# 	cd $struct_dir && crmd structural.Rmd > structural.Rout 2> structural.err
# 	echo "Done!"
# 	
# elif  [ "$1" == "--data" ]; then
# 	Rscript prepare_data.Rmd > prep_data.Rout
# 
# else 
#   output_dir=$paper_dir
#   echo "Directory: $output_dir"
#   echo "Copy config files..."
#   cp $config_dir/_output.yml $output_dir
#   cp $config_dir/*.py $output_dir
#   echo "Copy template, header, footer..."
#   cp Templates/* $output_dir/Templates
#   echo "Copy data and R code..."
#   cp .RData functions.R *.Rmd $output_dir
#   echo "Compile paper..."
#   cd $output_dir && crmd $main_file > report.Rout 2> report.err
#   echo "Move source code..."
#   mv *.Rmd Code/
#   echo "Done!"
# fi

## Sharable folder
# mkdir -p $share_dir
# cp $paper_dir/report.pdf $share_dir/mgh_report_$now.pdf
# cp $paper_docx_dir/report.docx $share_dir/mgh_report_$now.docx
# cp $paper_appendix/report_appendix.pdf $share_dir/mgh_appendix_$now.pdf

