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

source("prep-data.R")
source("regtab.R") # Regression tables
source('boxplot.R') # Customized boxplot
source('descriptives.R')	# Compute descriptives

save.image()