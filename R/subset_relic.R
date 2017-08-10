
```{r lastscore}
# Focus on the last score
# compute.score.last <- function(races, scores) {
# 	scores.ord <- scores[order(scores$timestamp), ]
# 	y.agg <- aggregate(final ~ coder_id, data=scores.ord, tail, n=1)
# 	colnames(y.agg)[2] <- "last"
# 	y.max <- merge(races, y.agg, by='coder_id', all=TRUE)
# 	aggregate(last ~ room_id + treatment + room_size, data=y.max, max)
# }
# final <- compute.score.last(races, scores)
# 
# Censoring
# final.baseline <- 0.792867
# final$last.raw <- final$last
# final$last <- ifelse(final$last.raw/1e6<0.792867, 0.792867, final$last.raw/1e6)
# par(mfrow=c(1, 3))
# form <- formula(last ~ treatment)
# boxplot.custom(form, data=final, main="All rooms")
# axis(1, at=1:3, levels(final$treatment))
# boxplot.custom(form, data=subset(final, room_size=='Small'), main="Small rooms\n(10 competitors)")
# axis(1, at=1:3, levels(final$treatment))
# boxplot.custom(form, data=subset(final, room_size=='Large'), main="Large rooms\n(15 competitors)")
# axis(1, at=1:3, levels(final$treatment))
######
# races$final_raw <- races$final
# races$final <-races$final_raw/1e6
# final <- add.covars(aggregate(final ~ room_id + treatment + room_size, data=races, max))
# 
# ### Deal with outliers
# outlier <- function(x) {
#   iqr <- IQR(x, na.rm=TRUE)
# 	low <- quantile(x, p=0.25, na.rm=TRUE) - 1.5*iqr
# 	x[x<low & !is.na(x)]
# }
# final.outline <- max(outlier(races$final))
# final.baseline <- 0.792867
# mean.censored <- function(x, low, base, ...) mean(ifelse(x<=low, base, x), ...)
# mean.censored(races$final, final.outline, final.baseline, na.rm=TRUE)
# prov <- aggregate(provisional ~ room + room_size + treatment, data=races, FUN=mean.trim, outlier=prov.out)
# 
```