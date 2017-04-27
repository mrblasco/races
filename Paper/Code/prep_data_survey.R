# % Dataset preparation Races vs Tournament
# % Andrea Blasco <ablasco@fas.harvard.edu>
rm(list=ls())
cat(format(Sys.time(), '%d %B, %Y'), sep='\n')
factorize <- function(x) factor(as.character(x), exclude=c(NA, ""))

read.csv("Data/Qualtrics/BANNER_registration_April+24%2C+2017_11.20.csv") -> dat.raw
questions <- dat.raw[1, ]
questions.id <- dat.raw[2, ]
write.table(questions, sep='\n', row.names=FALSE, col.names=FALSE, quote=FALSE)

dat.raw <- dat.raw[-c(1,2), ]

# Correct data
handle <- factorize(dat.raw$handle)
age <- factorize(dat.raw$age)
country <- factorize(dat.raw$cntry)
levels(country) <- gsub("^[A-Z]{2} - ","", levels(country))
educ <- factorize(dat.raw$Q19)
employ <- as.character(dat.raw$Q22)
gender <- factorize(dat.raw$gender)
plang <- factorize(dat.raw$Q21)
risk <- as.numeric(gsub("[^0-9]","", dat.raw$risk))
startdate <- strptime(dat.raw$StartDate,'%Y-%m-%d %H:%M:%S')
timezone  <- as.numeric(gsub("^([^,]+),.*", "\\1", dat.raw$tzone))
finished <- factorize(dat.raw$Finished)
duration <- as.numeric(as.character(dat.raw$Duration))
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

save(survey, file="survey.RData")
# pie(table(country))
# pie(table(plang))
# pie(table(educ))
# pie(table(age))
# pie(table(gender))
# barplot(table(risk))
# hist(duration/60) # Minutes
