#!/usr/bin/env Rscript
rm(list=ls())
set.seed(4881) # For imputations
setwd("/Users/ablasco/Documents/NTL/races")

# Scripts
source("Prep_data/prep_data_assign.R")
source("Prep_data/prep_data_survey.R")
source("Prep_data/prep_data_survey_final.R")
source("Prep_data/prep_data_scores.R")
source("Prep_data/prep_data_merge.R")

# Archive intermediate files
system("ditto Prep_data/* races_*.RData \"Data/R/`date +%b%d`\"")
system("rm races_*.RData")

# Prepare workspace
rm(list=setdiff(ls(), c("final_survey", "races", "scores", "survey")))
source("help_functions.R")

# Util functions
report <- function() {
	system('sh compile.sh report.Rmd Paper')
}

prepdata <- function() {
	system('Rscript Prep_data/prep_workspace.R')
	q(save="no")
}

 
save.image()