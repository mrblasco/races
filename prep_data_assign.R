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
reg.raw <- read.csv("Data/registered_platform_topcoder.txt", sep='\t')
assign.raw  <- rbind(read.csv("Data/Assignment/race.csv")
              , read.csv("Data/Assignment/tournament.csv")
              , read.csv("Data/Assignment/reserve.csv"))

handle <- as.character(reg.raw$handle)
member_date <- as.Date(strptime(reg.raw$create_date, format='%m/%d/%Y', tz=''))
algo_rating <- as.numeric(reg.raw$algorating)
algo_events <- as.numeric(reg.raw$algoevents)
algo_reg <- as.numeric(reg.raw$algoreg)
mm_rating <- as.numeric(reg.raw$mmrating)
mm_events <- as.numeric(reg.raw$mmevents)
mm_reg <- as.numeric(reg.raw$mmreg)

coders <- data.frame(handle, member_date, algo_reg, algo_rating, algo_events, mm_reg, mm_rating, mm_events)

# 
handle <- assign.raw$handle
treatment <- assign.raw$treatment_id
room <- assign.raw$room_id
room_size <- assign.raw$room_type_id	
assign.0 <- data.frame(handle, treatment, room, room_size)

# Merge
races <- merge(assign.0, coders, by="handle", all=TRUE)

# Consistent data
index <- tapply(1:nrow(races), races$handle, head, 1)
rownames(index) <- NULL
races <- races[index, ]

save(races, file="Data/races_assign.RData")
