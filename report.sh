#!/bin/bash
Rscript -e "rmarkdown::render('Paper/_report.Rmd')"
open -a Skim Paper/_report.pdf