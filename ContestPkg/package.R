#!/usr/bin/env Rscript
#****************************************#
library(devtools)
library(roxygen2)
options("devtools.desc.author"="person(\"Andrea\", \"Blasco\", email = \"ablasco@fas.harvard.edu\", role = c(\"aut\", \"cre\"))")

# Package Name
pkgname <- "contest" 


# Package description
desc <- list(
	Title="Contest simulation package", Version="0.1",
	Description="This package contains script to simulate contest model of races and tournaments."
)

# Create package
folder <- pkgname
create(folder, description=desc, rstudio=FALSE)
system(paste("cp contest.R ", folder, "/R", sep="")) # Copy source files
document(folder)
install(folder)  
## END
