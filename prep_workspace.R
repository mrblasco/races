#!/usr/bin/env Rscript
rm(list=ls())
setwd("/Users/ablasco/Documents/NTL/races")

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