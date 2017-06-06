#!/usr/bin/env Rscript
#****************************************#
library(devtools)
library(roxygen2)


#****************************************#
# Create dataset
#****************************************#
source("prep_data_assign.R")
source("prep_data_survey.R")
source("prep_data_survey_final.R")
source("prep_data_scores.R")
source("prep_data_merge.R")

#****************************************#
# Package information
#****************************************#
pkgname <- "races" # Package name
options("devtools.desc.author"="person(\"Andrea\", \"Blasco\", email = \"ablasco@fas.harvard.edu\", role = c(\"aut\", \"cre\"))")
desc <- list(
  Title = "Package for xxxx.",
  Version = "0.1",
  Description = "This package does x, y, z.")

#****************************************#
# Create package in temp directory
#****************************************#
tmp_dir <- file.path(tempdir(), pkgname)
create(tmp_dir, description=desc, rstudio=FALSE)
use_data(races, scores, final_survey, pkg=tmp_dir)
system(paste("cp package_definitions.R ", tmp_dir, "/R", sep="")) # Copy source files
document(tmp_dir) # Create documentation    
install(tmp_dir)  # remove.packages(pkgname)
## END
