#!/usr/bin/env Rscript
#****************************************#
library(devtools)
library(roxygen2)
options("devtools.desc.author" = 
			"person(\"Andrea\", \"Blasco\", email=\"ablasco@fas.harvard.edu\", role=c(\"aut\", \"cre\"))")


#****************************************#
# Create dataset
#****************************************#
source("1_assign.R")
source("2_survey.R")
source("3_survey_final.R")
source("4_scores.R")
source("5_merge.R")
source("6_cleanup.R")

#****************************************#
# Package information
#****************************************#
desc <- list()
desc$Title <- 'Data for the paper: \"Races or Tournaments? Theory and Evidence from a Field Experiment\"'
desc$Description <- 'Data from the field experiment described in the paper: \"Races or Tournaments? Theory and Evidence from a Field Experiment\"'
desc$Version="0.3"

#****************************************#
# Create package in folder and install
#****************************************#
create.package <- function(folder, desc, ...) {
	if (file.exists(folder)) {
		file.rename(folder, paste(folder, "old",sep="_"))
	}
	create(folder, description=desc, rstudio=FALSE)
	use_data(..., pkg=folder)
	file.copy("package_definitions.R", paste(folder,"R", sep="/"))
	document(folder) # Create documentation    
	install(folder)  # remove.packages(pkgname)
}


create.package(folder="races", desc=desc, races, scores, final_survey)
## END
