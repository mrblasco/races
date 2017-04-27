# % Dataset preparation Races vs Tournament
# % Andrea Blasco <ablasco@fas.harvard.edu>
format(Sys.time(), '%d %B, %Y')
rm(list=ls())
library(magrittr)
library(jsonlite)
library(xtable)
library(knitr)
source("help_prep_data.R")

# Files
output <- ".RData"
output.identity <- ".handles"

# For imputations
set.seed(4881)
 
# Upload data
regdata.raw <- read.csv("Data/registered_platform_topcoder.txt", sep='\t')
subs.raw    <- read.csv("Data/submissions.csv")
svy.ini.raw <- read.csv("Data/initial_survey.csv", na.strings=c("","NA")) 
svy.end.raw <- read.csv("Data/final_survey.csv", na.strings=c("","NA"))
assign.raw  <- rbind(read.csv("Data/Assignment/race.csv")
              , read.csv("Data/Assignment/tournament.csv")
              , read.csv("Data/Assignment/reserve.csv"))

# Correct registration data 
regdata.correct <- function(x) {
  x$handle <- standardize.handle(x$handle)
  x$create_date <- strptime(x$create_date, format='%m/%d/%Y', tz='')  
  x$country_name <- factor(as.character(x$country_name))
  x$algorating <- as.numeric(x$algorating)
  x$algoevents <- as.numeric(x$algoevents)
  x$mmrating <- as.numeric(x$mmrating)
  x$mmevents <- as.numeric(x$mmevents)
  x$mmevents <- impute.zero(x$mmevents)
  x$algoreg <- as.numeric(x$algoreg)
  x$mmreg <- as.numeric(x$mmreg)
  x$address <- NULL # Email address
  x$school <- NULL 	# ... 
  x$age <- NULL 	# This is age at registration
  x$gender <- NULL 	# ... 
  breaks <- 100*round(quantile(x$totalpayments, na.rm=TRUE) / 100)
  breaks.lab <- c("0", "1 - 599", "600 - 4500","4500 - 37000",">37000")
  x$totalpayments %>% impute.zero %>% as.numeric %>%
    cut(breaks=c(0, 1, breaks[-1]), include.lowest=TRUE, right=FALSE) %>%
    factor(labels=breaks.lab) -> x$totalpayments
  return(x)
}

# Consistent registration data
regdata.consistent <- function(x) {
  x <- unique.by.id(x, x$handle)
  for (i in 1:ncol(x)) {   # Numeric must be non-negative numbers
    if (is.numeric(x[, i])) {x[, i][x[, i]<0] <- 0}
  }
  # Impute missing values
  # ... 
  return(x)
}

# Assigned treatments
assign.correct <- function(x) {
  names(x) <- gsub("_id", "", names(x))
  x$handle <- standardize.handle(x$handle)
  x$mmrating <- NULL
  return(x)
}

assign.consistent <- function(x) {
  x$room <- factor(paste("Group ", ifelse(x$treatment=="race", "1", ifelse(x$treatment=="tournament", "2", "3")), toupper(letters[x$room]), sep=""))
  levels(x$treatment) <- capitalize(levels(x$treatment))
  return(x)
}

# Initial Survey
svy.ini.correct <- function(x) {
  x <- x[, -c(1:7, grep("info_|thank", names(x)), ncol(x))] # Drop Qualtrics vars
  x$handle    <- standardize.handle(x$handle)  
  x$startdate <- strptime(x$startdate,'%Y-%m-%d %H:%M:%S', tz='EST')
  x$enddate   <- strptime(x$enddate,'%Y-%m-%d %H:%M:%S', tz='EST')
  x$finished  <- as.logical(x$finished==1)
  x$age       <- factor(as.character(x$age))
  x$country_origin <- factor(gsub("^[A-Z]{2} - ", "", x$country_origin))
  x$educ      <- factor(as.character(x$educ))
  levels(x$educ) <- c("PhD", "High School", "Master of Arts", "Bachelor")
  x$gender    <- factor(as.character(x$gender))
  x$employ    <- tolower(as.character(x$employ))
  x$plang     <- factor(as.character(x$plang))
  x$risk      <- as.numeric(gsub("[^0-9]","", as.character(x$risk)))
  x$timezone  <- as.numeric(gsub("^([^,]+),.*", "\\1",x$timezone))
  return(x)
}
svy.ini.consistent <- function(x) {
  # Order by missing values
  tot.missing <- numeric(nrow(x))
  for (i in 1:nrow(x)) {
    tot.missing[i] <- na.count(x[i,])
  }
  x <- x[order(tot.missing, decreasing=FALSE), ]
  x <- unique.by.id(x, x$handle)
  return(x)
}

# Final survey
svy.end.correct <- function(x) {
  x <- x[, -c(1:7, 31:ncol(x), grep("info|thanks",names(x)))]
  x$handle     <- standardize.handle(x$handle)
  x$startdate  <- strptime(x$startdate,'%Y-%m-%d %H:%M:%S', tz='EST')
  x$enddate    <- strptime(x$enddate,'%Y-%m-%d %H:%M:%S', tz='EST')
  x$finished   <- as.logical(x$finished==1)
  x$risk       <- as.numeric(gsub("[^0-9]","", as.character(x$risk)))
  x$approaches <- as.character(x$approaches)
  x$racing_thoughts <- as.character(x$racing_thoughts)
  return(x)
}
svy.end.consistent <- function(x) {
  tot.missing <- numeric(nrow(x))
  for (i in 1:nrow(x)) {
    tot.missing[i] <- na.count(x[i,])
  }
  x <- x[order(tot.missing, decreasing=FALSE), ]
  x <- unique.by.id(x, x$handle)
  return(x)
}


# Scores and submissions
subs.correct <- function(x) {
  names(x) <- tolower(names(x))
  names(x)[grep("submissionid", names(x))] <- "id"
  names(x)[grep("roomid", names(x))] <- "room"
  names(x)[grep("^timestamp$", names(x))] <- "timestamp"
  names(x)[grep("^timestamp2$", names(x))] <- "timestamp2"
  x$epochtime <- NULL
  x$handle2 <- NULL
  x$timestamp2 <- NULL
  x$handle <- standardize.handle(x$handle)
  x$id <- as.numeric(x$id)
  x$timestamp <- strptime(x$timestamp, "%Y-%m-%d %H:%M:%S") 
  x$system <- as.numeric(x$system)
  x$provisional <- as.numeric(x$provisional)
  return(x)
}
subs.consistent <- function(x) {
  x$system <- impute.zero(x$system)
  return(x)
}


# Prepare all data
summary(regdata <- regdata.consistent(regdata.correct(regdata.raw)))
summary(assignment <- assign.consistent(assign.correct(assign.raw)))
summary(svy.ini <- svy.ini.consistent(svy.ini.correct(svy.ini.raw)))
summary(svy.end <- svy.end.consistent(svy.end.correct(svy.end.raw)))
summary(subs <- subs.consistent(subs.correct(subs.raw)))

# Merge datasets

## Checks before merging
### Handles assigned but not in registration data
length(setdiff(assignment$handle, regdata$handle))
### Handles assigned but not in initial survey
length(setdiff(assignment$handle, svy.ini$handle))


# Merge and impute
newdata   <- merge(regdata, assignment, by='handle')
newdata2  <- merge(newdata, svy.ini, by="handle", suff=c("",".ini"), all.x=TRUE)
newdata3  <- merge(newdata2, svy.end, by="handle", all.x=TRUE, suff=c("",".end"))

final.consistent <- function(x) {
  x$age <- impute.at.random(x$age)$imputed
  x$gender <- impute.at.random(x$gender)$imputed
  x$plang <- impute.at.random(x$plang)$imputed
  
  # Education associated with age --> imputing at random | age
  tab <- table(x$age, x$educ)
  print(chisq.test(tab)) ## Show association before imputing
  prob <- prop.table(tab+1, 1)
  educ.miss <- is.na(x$educ)
  age.miss <- x$age[educ.miss]
  x$educ[educ.miss] <- sapply(age.miss, 
      function(z) sample(levels(x$educ), size=1, replace=TRUE, prob=prob[z, ]))
  #(match(levels(x$educ), colnames(prob)))
  # Timezone fixed association with country --> imputing at random | country
  prob <- prop.table(table(droplevels(x$country_name), x$timezone), 1)
  prob["South Africa", ] <- rep(0, ncol(prob))
  prob["South Africa", "2"] <- 1 
  tz.miss <- is.na(x$timezone)
  country.miss <- x$country_name[tz.miss]
  x$timezone[tz.miss] <- sapply(country.miss, 
      function(z) sample(as.numeric(colnames(prob))
      , size=1, replace=TRUE, prob=prob[z, ]))
  return(x)
}



summary(races <- final.consistent(newdata3))
races.sub <- subs
races$submit <- races$handle %in% races.sub$handle

# De-identify the data
de.identify <- function(x) {
  x <- droplevels(x)
  old.levels <- levels(x)
  new.levels <- 1:length(old.levels)
  x.new <- factor(x, labels=new.levels)
  return(list(x=x.new, identity=old.levels))
}
z <- de.identify(races$handle)

# Replace handles
races.sub$handle <- match(races.sub$handle, z$identity)
races$handle <- z$x

# Create panel
create.panel <- function(races, races.sub) {
	id <- levels(races$handle)
	dat <- expand.grid(days=1:4, id=id)
	dat$hours <- NA
	dat$hours[dat$days==1] <- races$hours1
	dat$hours[dat$days==2] <- races$hours2
	dat$hours[dat$days==3] <- races$hours3
	dat$hours[dat$days==4] <- races$hours4
	submission.start <- strptime("2015-03-08 12:00",'%Y-%m-%d %H:%M') 
	submission.end <- strptime("2015-03-15 13:00",'%Y-%m-%d %H:%M')
	difference <- difftime(races.sub$timestamp, submission.start, unit="hours")
	days <- as.numeric(difference) %/% 48 + 1
	races.sub$nsub <- 1
	nsub.agg <- with(races.sub, aggregate(nsub ~ days + handle, FUN=length))
	panel <- merge(dat, nsub.agg
			, by.x=c("days", "id")
			, by.y=c("days", "handle"), all=TRUE)
	panel$nsub[is.na(panel$nsub)] <- 0
	index <- match(panel$id, races$handle)
	panel$treatment <- races$treatment[index]
	return(panel)
}

panel <- create.panel(races, races.sub)

# SAVE ########################################################################
write.table(z$identity, quote=F, sep=",", col.names=FALSE, file=output.identity)
save(list=c("races", "races.sub", "panel"), file=output)
################################################################################

