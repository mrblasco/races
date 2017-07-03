#!/usr/bin/env Rscript
#****************************************#
library(devtools)
library(roxygen2)
options("devtools.desc.author"="person(\"Andrea\", \"Blasco\", email = \"ablasco@fas.harvard.edu\", role = c(\"aut\", \"cre\"))")


#****************************************#
# Create dataset
#****************************************#
source("1_assign.R")
source("2_survey.R")
source("3_survey_final.R")
source("4_scores.R")
source("5_merge.R")

#****************************************#
# Package information
#****************************************#
pkgname <- "races" # Package name
desc <- list(Title="Package for the paper: \"Races or Tournaments?\"", Version="0.2",
	Description="This package for \"Races or Tournaments? Theory and Evidence from a Field Experiment\"",
	LazyData="true")

#****************************************#
# Create package in folder and install
#****************************************#
create.package <- function(folder) { 
	create(folder, description=desc, rstudio=FALSE)
	use_data(races, scores, final_survey, pkg=folder)
	system(paste("cp package_definitions.R ", folder, "/R", sep="")) # Copy source files
	document(folder) # Create documentation    
	install(folder)  # remove.packages(pkgname)
}
create.package("races")
## END
