# 
# Entry
# 
# 


## @knitr entryPlot

entry.large <- subset(entry, room_size=='Large')
entry.small <- subset(entry, room_size=='Small')


ylim=c(0, .6)
par(mfrow=c(1, 3))
boxplot(submit/n ~ treatment, data=entry, main="All rooms", ylim=ylim)
boxplot(submit/n ~ treatment, data=entry.small, main="Small rooms\n(10 competitors)", ylim=ylim)
boxplot(submit/n ~ treatment, data=entry.large, main="Large rooms\n(15 competitors)", ylim=ylim)

# Mean and percentage of room entrants
entry.diff <- round(with(entry, tapply(submit, treatment, mean)), 1)
entry.pcnt <- round(with(entry, 100*tapply(submit/n, treatment, mean)), 1)

# par(mfrow=c(1, 3)); ylim=c(0, .6)
# form <- formula(submit/n ~ treatment)
# boxplot.custom(form, data=entry, main="All rooms", ylim=ylim)
# boxplot.custom(form, data=subset(entry, room_size=='Small'), main="Small rooms\n(10 competitors)", ylim=ylim)
# boxplot.custom(form, data=subset(entry, room_size=='Large'), main="Large rooms\n(15 competitors)", ylim=ylim)


## @knitr entrylm

# Fit the model 
m <- rep()
m$entry.lm <- lm(submit/n ~ treatment + room_size, data=entry)
m$entry.lm.partial <- update(m$entry.lm, ~ . + nwins + ntop10 + timezone + postgrad + male)
m$entry.lm.full <- lm(submit/n ~ . -hours12-hours34-hours56-hours78, data=entry[, -1])
m.log <- lapply(m, function(x) update(x, "log(submit/n) ~ ."))

# Summarize regressions
entry.lm.sum <- summary(m$entry.lm) 
entry.lm.log.sum <- summary(m.log$entry.lm)

# Print latex table
regtab(c(m, m.log), digits=3, notes.width=1, keep.stat=c('n','rsq')
	, omit="nwins|hours|rating|nreg|nsub|ntop|risk|male|time|postgrad|below|paid|year"
	, add.lines=list(c("Room controls", rep(c("no controls", "partial", "full"), 2)))
	, dep.var.labels=c("Entry/n","log(Entry/n)")
	, covariate.labels=c("Tournament","Tournament w/reserve", "Room size (small)")
	, notes="The table reports regression estimates of the effects of different competition styles on entry computed using three sets of room controls: ``no controls\", ``partial\", ``full.\" Standard errors are reported in parenthesis. ***,**, * indicate statistical significance at 1, 5, and 10 percent level."
	, caption="Estimates of the effects of competition and room size on entry"
	, label='ols entry')
