#!/bin/bash

Rscript -e "rmarkdown::render('Notebook/_note.Rmd')"

open -a Skim Notebook/_note.pdf