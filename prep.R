#!/usr/bin/env Rscript
rm(list=ls())
setwd("/Users/ablasco/Documents/NTL/races")

#************************************************#
# Helper functions
#************************************************#
render <- function(type=c("p","n","s"))  {
	system(sprintf('sh compile.sh -%s', type))
}
percent  <- function(x, digits=0, ...) round(100 * x, digits, ...)
difftime2 <- function(...) as.numeric(difftime(...))


# Print regression tables 
source("Paper/regtab.R")


save.image()