rm(list=ls())
load("races_merged.RData")

# RACES data set
dim(races)
names(races)
summary(races)

# Adjust variables
dat <- races

## Rename variables
dat$mm_rating <- NULL
dat$finished <- NULL
names(dat)[names(dat)=='mm_reg'] <- "nreg"
names(dat)[names(dat)=='mm_events'] <- "nsub"
names(dat)[names(dat)=='ave_nsub_past'] <- "ave_code"
names(dat)[names(dat)=='algo_events'] <- "algo_nsub"
names(dat)[names(dat)=='algo_reg'] <- "algo_nreg"
names(dat)[names(dat)=='mm_rating2'] <- "rating"
names(dat)[names(dat)=='mm_rating_max'] <- "rating_max"
names(dat)[names(dat)=='mm_rating_min'] <- "rating_min"
names(dat)[names(dat)=='lastround'] <- "recentsub"
names(dat)[names(dat)=='duration'] <- "svy_seconds"
names(dat)[names(dat)=='startdate'] <- "svy_date"


## Create new variables
dat$room_id <- as.factor(with(dat, paste(treatment, room)))
dat$year <- as.numeric(format(dat$member_date, '%Y'))
dat$male <- dat$gender=='Male'
dat$gender <- NULL
dat$hours <- with(dat, week1 + week2 + week3 + week4)
dat$svy_date <- as.Date(dat$svy_date)
dat$rating <- dat$rating/100
dat$rating_max <- dat$rating_max/100
dat$rating_min <- dat$rating_min/100

levels(dat$educ) <- c("PhD", "High School", "Postgraduate (MA)", "Undergraduate (BA)")
levels(dat$age) <- c("<20", "20-25", "26-30", "31-40", ">40")

# Save races
races <- dat

# vars <- c("paid", "rating", "volatility", "lnreg", "nreg", "nsub", "ave_code")
# plot(races[, vars], cex=.75, pch=16, col=ifelse(races$submit,"brown","navy"))
summary(races)
