#!/usr/bin/env Rscript
rm(list=ls())

#*****************************************#
# Dataset preparation Races vs Tournament #
# Andrea Blasco <ablasco@fas.harvard.edu> #
#*****************************************#

output.file <- "races_survey_final.RData"
input <- "Data/Qualtrics/BANNER_final_April+24%2C+2017_11.21.csv"


#*****************************************#
#  Helper functions
#*****************************************#
factorize <- function(x, ...) factor(as.character(x), exclude=c(NA, ""), ...)

clean.handle <- function(x) {
	x <- trimws(tolower(x))
	x <- gsub("@gmail.com","",x)
	x <- gsub("vidhyabhushan.*", "vidhyabhushanv", x)
	return(x)
}


#*****************************************#
#  Prepare data
#*****************************************#
read.csv(input) -> dat.raw
questions <- dat.raw[1, ]
questions.id <- dat.raw[2, ]
write.table(questions, sep='\n', row.names=FALSE, col.names=FALSE, quote=FALSE)
dat.raw <- dat.raw[-c(1,2), ]

# Correct variables
handle <- factorize(clean.handle(dat.raw$handle))
finished <- factorize(dat.raw$Finished)
startdate <- strptime(dat.raw$StartDate,'%Y-%m-%d %H:%M:%S')
duration <- as.numeric(as.character(dat.raw$Duration))
week1 <- as.numeric(as.character(dat.raw$week_1_13))
week2 <- as.numeric(as.character(dat.raw$week_2_13))
week3 <- as.numeric(as.character(dat.raw$week_3_13))
week4 <- as.numeric(as.character(dat.raw$week_4_13))
twice <- factorize(as.character(dat.raw$double), levels=c("The same", "10% more", "20% more", "30% more", "40 % more", "50% more", "> 50% more"))
halve <- factorize(as.character(dat.raw$Q16), levels=c("The same", "10% less", "20% less", "30% less", "40 % less", "50% less", "> 50% less"))
hard <- factorize(as.character(dat.raw$hard), levels=c("Very Difficult", "Difficult", "Somewhat Difficult", "Neutral", "Somewhat Easy", "Easy","Very Easy"))
risk2 <- as.numeric(gsub("[^0-9]","", dat.raw$risk))

# Writeups
ml_methods <- levels(dat.raw$Q18)


# Correct dataset
survey <- data.frame(handle, duration, finished, startdate, week1, week2, week3, week4, twice, halve, hard, risk2)

# Consistent dataset
index <- tapply(1:nrow(survey), survey$handle, head, 1)
rownames(index) <- NULL
final_survey <- survey[index, ]

#### SAVE
save(final_survey, file=output.file)

