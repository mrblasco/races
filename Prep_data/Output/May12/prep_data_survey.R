# % Dataset preparation Races vs Tournament
# % Andrea Blasco <ablasco@fas.harvard.edu>
rm(list=ls())
cat(format(Sys.time(), '%d %B, %Y'), sep='\n')
factorize <- function(x) factor(as.character(x), exclude=c(NA, ""))
clean.handle <- function(x) {
	x <- trimws(tolower(x))
	x <- gsub("@gmail.com","",x)
	x <- gsub("vidhyabhushan.*", "vidhyabhushanv", x)
	return(x)
}

output.file <- "races_survey.RData"
input <- "Data/Qualtrics/BANNER_registration_April+24%2C+2017_11.20.csv"

# Load data
read.csv(input) -> dat.raw
questions <- dat.raw[1, ]
questions.id <- dat.raw[2, ]
write.table(questions, sep='\n', row.names=FALSE, col.names=FALSE, quote=FALSE)
dat.raw <- dat.raw[-c(1,2), ]

# Correct variables
handle <- factorize(clean.handle(dat.raw$handle))
age <- factorize(dat.raw$age)
levels(age)[levels(age)=="41-50 years"] <- ">40 years"
levels(age)[levels(age)=="51 years and above"] <- ">40 years"
country <- factorize(dat.raw$cntry)
levels(country) <- gsub("^[A-Z]{2} - ","", levels(country))
educ <- factorize(dat.raw$Q19)
gender <- factorize(dat.raw$gender)
plang <- factorize(dat.raw$Q21)
levels(plang)[levels(plang)=="VB"] <- "Other"
finished <- factorize(dat.raw$Finished)
employ <- as.character(dat.raw$Q22)
startdate <- strptime(dat.raw$StartDate,'%Y-%m-%d %H:%M:%S')
timezone  <- as.numeric(gsub("^([^,]+),.*", "\\1", dat.raw$tzone))
duration <- as.numeric(as.character(dat.raw$Duration))
risk <- as.numeric(gsub("[^0-9]","", dat.raw$risk))
week1 <- as.numeric(as.character(dat.raw$week_1_13))
week2 <- as.numeric(as.character(dat.raw$week_2_13))
week3 <- as.numeric(as.character(dat.raw$week_3_13))
week4 <- as.numeric(as.character(dat.raw$week_4_13))

# Correct dataset
survey <- data.frame(handle, age, duration, educ, finished, gender, country, plang, risk, startdate, timezone, week1, week2, week3, week4)

# Consistent dataset
index <- tapply(1:nrow(survey), survey$handle, head, 1)
rownames(index) <- NULL
survey <- survey[index, ]

save(survey, file=output.file)