#!/usr/bin/env Rscript
cat(format(Sys.time(), '%d %B, %Y'),sep="\n")
rm(list=ls())

# Data 
input <- "Data/submissions.csv"
output <- "races_scores.RData"
subs.raw    <- read.csv(input)

# Correct variables 
handle <- as.character(subs.raw$handle)
timestamp <- strptime(subs.raw$timestamp, format="%Y-%m-%d %H:%M:%S", tz='')
provisional <- as.numeric(subs.raw$provisional)
final <- as.numeric(subs.raw$system)
submission <- as.numeric(subs.raw$submissionID)

# Data frame
scores <- data.frame(handle, submission, timestamp, provisional, final)
summary(scores)

# Save
save(scores, file=output)


# Cross section
# scores.1 <- subset(scores, submission==1)
# plot(sort(scores.1$timestamp), 1:nrow(scores.1))