# % Dataset preparation Races vs Tournament
# % Andrea Blasco <ablasco@fas.harvard.edu>
format(Sys.time(), '%d %B, %Y')
rm(list=ls())

output.file <- 'races_merged.RData'

load("races_scores.RData")
load("races_survey.RData")
load("races_survey_final.RData")
load("races_assign.RData")


#*****************************************#
#  Merge files
#*****************************************#

# Create list with unique handles
handles <- c(levels(races$handle), levels(scores$handle), levels(survey$handle), levels(final_survey$handle))
ids <- unique(tolower(handles))

# Match handle id with handle
races$coder_id <- match(tolower(races$handle), ids)
races$handle <- NULL
survey$coder_id <- match(tolower(survey$handle), ids)
survey$handle <- NULL
final_survey$coder_id <- match(tolower(final_survey$handle), ids)
final_survey$handle <- NULL

# Merge data by id
races2 <- merge(races, survey, by="coder_id", all.x=TRUE)
# summary(races2)

# Match handle id for scores
scores$coder_id <- match(tolower(scores$handle), ids)
scores$handle <- NULL

#*****************************************#
#  Create new variables
#*****************************************#

races2$submit <- races2$coder_id %in% scores$coder_id

# Form scores cross section
scores.ord <- scores[order(scores$coder_id, scores$timestamp), ]
i <- tapply(1:nrow(scores.ord), scores.ord$coder_id, tail, 1)
scores.cs <- scores.ord[i, ]

# Merge races with cs scores
races3 <- merge(races2, scores.cs, by='coder_id', all.x=TRUE)

# Missing values
races3$submission[is.na(races3$submission)] <- 0

#*****************************************#
#  Save
#*****************************************#
races <- races3

save(races, scores, survey, final_survey, file=output.file)
