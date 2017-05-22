#!/bin/bash
#***********************************************#
# Prepare workspace data for Races vs Tournament
#
# Andrea Blasco <ablasco@fas.harvard.edu>
#***********************************************#
now=`date +%b%d`
current_dir=`pwd`
prep_data_dir=Prep_data
temp_dir=$(mktemp -d)

# Preliminary steps
cp $prep_data_dir/* $temp_dir
cp help_functions.R $temp_dir
cd $temp_dir
ln -s $current_dir/Data Data

compile () {
	Rscript prep_data_assign.R
	Rscript prep_data_survey.R
	Rscript prep_data_survey_final.R
	Rscript prep_data_scores.R
	Rscript prep_data_merge.R
	Rscript prep_workspace.R
}
compile > log_$now.txt

cd $current_dir
ditto $temp_dir $prep_data_dir/Output/$now
