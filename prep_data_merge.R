# % Dataset preparation Races vs Tournament
# % Andrea Blasco <ablasco@fas.harvard.edu>
format(Sys.time(), '%d %B, %Y')
rm(list=ls())

load("Data/races_scores.RData")
load("Data/races_survey.RData")
load("Data/races_assign.RData")

# Merge datasets
handles <- c(levels(races$handle), levels(scores$handle), levels(survey$handle))
ids <- unique(tolower(handles))

# Merge races + survey
races$coder_id <- match(tolower(races$handle), ids)
races$handle <- NULL
survey$coder_id <- match(tolower(survey$handle), ids)
survey$handle <- NULL

races2 <- merge(races, survey, by="coder_id", all.x=TRUE)
summary(races2)

scores$coder_id <- match(tolower(scores$handle), ids)
scores$handle <- NULL
#setdiff(scores$coder_id, races2$coder_id)
races2$submit <- races2$coder_id %in% scores$coder_id

races <- races2
save(races, scores, survey, file='.RData')
