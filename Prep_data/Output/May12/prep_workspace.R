#!/usr/bin/env Rscript
cat(format(Sys.time(), '%d %B, %Y'),sep="\n")
rm(list=ls())

load('races_merged.RData')
source("help_functions.R")

save.image()