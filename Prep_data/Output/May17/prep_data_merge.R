# % Dataset preparation Races vs Tournament
# % Andrea Blasco <ablasco@fas.harvard.edu>
format(Sys.time(), '%d %B, %Y')
rm(list=ls())

output.file <- 'races_merged.RData'

load("races_scores.RData")
load("races_survey.RData")
load("races_survey_final.RData")
load("races_assign.RData")

# Merge deatasets
handles <- c(levels(races$handle), levels(scores$handle), levels(survey$handle), levels(final_survey$handle))
ids <- unique(tolower(handles))

# Merge races + survey
races$coder_id <- match(tolower(races$handle), ids)
races$handle <- NULL
survey$coder_id <- match(tolower(survey$handle), ids)
survey$handle <- NULL
final_survey$coder_id <- match(tolower(final_survey$handle), ids)
final_survey$handle <- NULL


races2 <- merge(races, survey, by="coder_id", all.x=TRUE)
summary(races2)

scores$coder_id <- match(tolower(scores$handle), ids)
scores$handle <- NULL
#setdiff(scores$coder_id, races2$coder_id)
races2$submit <- races2$coder_id %in% scores$coder_id

races <- races2

save(races, scores, survey, final_survey, file=output.file)
