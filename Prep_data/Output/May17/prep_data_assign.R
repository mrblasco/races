#!/usr/bin/env Rscript
rm(list=ls())
set.seed(4881) # For imputations

#*****************************************#
# Dataset preparation Races vs Tournament #
# Andrea Blasco <ablasco@fas.harvard.edu> #
#*****************************************#

output.file <- "races_assign.RData"

# Upload data
assign.raw  <- rbind(read.csv("Data/Assignment/race.csv")
              , read.csv("Data/Assignment/tournament.csv")
              , read.csv("Data/Assignment/reserve.csv"))
reg.raw <- read.csv("Data/registered_platform_topcoder.txt", sep='\t')
details.raw <- read.csv("Data/details_profile.csv", sep=',') 

# Basic stats
cat(sprintf("# pre-registered = %i\n", nrow(reg.raw)))
cat(sprintf("# assigned = %i\n", nrow(assign.raw)))
cat(sprintf("# platform data = %i\n", nrow(assign.raw)))


#*****************************************#
#  Helper functions
#*****************************************#
clean.handle <- function(x) {
	x <- trimws(tolower(x))
	return(x)
}
impute.zero <- function(x) {
	if (!is.numeric(x)) stop("Variable is not numeric!")
	x[is.na(x)] <- 0
	return(x)
}

#*****************************************#
#  Registered competitors
#*****************************************#

# Correct format
handle <- clean.handle(as.character(reg.raw$handle))
member_date <- as.Date(strptime(reg.raw$create_date, format='%m/%d/%Y', tz=''))
algo_rating <- as.numeric(reg.raw$algorating)
algo_events <- as.numeric(reg.raw$algoevents)
algo_reg <- as.numeric(reg.raw$algoreg)
mm_rating <- as.numeric(reg.raw$mmrating)
mm_events <- as.numeric(reg.raw$mmevents)
mm_reg <- as.numeric(reg.raw$mmreg)
paid <- as.numeric(reg.raw$totalpayments)

# Consistent data
mm_events 	<- impute.zero(mm_events)
mm_reg 		<- impute.zero(mm_reg)
algo_events <- impute.zero(algo_events)
algo_reg 	<- impute.zero(algo_reg)

# Data frame
coders <- data.frame(handle, member_date, algo_reg, algo_rating, algo_events, mm_reg, mm_rating, mm_events, paid)

#*****************************************#
#  Merge with assignment data
#*****************************************#

# Correct format
handle <- clean.handle(assign.raw$handle)
treatment <- assign.raw$treatment_id
room <- assign.raw$room_id
room_size <- assign.raw$room_type_id	
assignment <- data.frame(handle, treatment, room, room_size)

# Merge
races.1 <- merge(assignment, coders, by="handle", all.x=TRUE)

missed_matches <- !handle %in% coders$handle
cat(sprintf("# NOT merged with registration data = %i\n", sum(missed_matches)))

#*****************************************#
#  Merge with other details
#*****************************************#

# Correct format
handle <- clean.handle(details.raw$Handle)
nwins <- details.raw$Num.Wins
ntop10 <- details.raw$Num.Top.10
lastround <- as.Date(details.raw$Last.Round.Date, '%m/%d/%Y')
dat <- data.frame(handle, nwins, ntop10, lastround)

# Merge
races.2 <- merge(races.1, dat, by='handle', all.x=TRUE)

missed_matches <- !handle %in% races.1$handle
cat(sprintf("# NOT merged with platform data = %i\n", sum(missed_matches)))


#*****************************************#
#  Final checks & save
#*****************************************#
races <- races.2

index <- tapply(1:nrow(races), races$handle, head, 1)
rownames(index) <- NULL
races <- races[index, ]

save(races, file=output.file)
