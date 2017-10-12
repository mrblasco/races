################################################################################
# 
#	This script is for the analysis of entry
#
# List of chunks: 
# 	entryPlot: "Percentage Of Room Entrants By Competition And Room Size"
#		entrylm: "Ols Estimates Of The Effects Of Competition And Room Size On Entry"
################################################################################


########################################
## @knitr entry_rates_figure
########################################

entry.large <- subset(entry, room_size=='Large')
entry.small <- subset(entry, room_size=='Small')

ylim=c(0, .6)
par(mfrow=c(1, 3))
boxplot(submit/n ~ treatment, data=entry, main="All rooms", ylim=ylim)
boxplot(submit/n ~ treatment, data=entry.small, main="Small rooms\n(10 competitors)", ylim=ylim)
boxplot(submit/n ~ treatment, data=entry.large, main="Large rooms\n(15 competitors)", ylim=ylim)
axis(side=1,at=2)

# Mean and percentage of room entrants
entry.diff <- round(with(entry, tapply(submit, treatment, mean)), 1)
entry.pcnt <- round(with(entry, 100*tapply(submit/n, treatment, mean)), 1)

########################################
## @knitr entrylm
########################################
m <- rep()
m$entry.lm <- lm(submit/n ~ treatment + room_size, data=entry)
m$entry.lm.partial <- update(m$entry.lm, ~ . + nwins + ntop10 + timezone + postgrad + male)
m$entry.lm.full <- lm(submit/n ~ . -hours12-hours34-hours56-hours78, data=entry[, -1])

# Exponential model
m.log <- lapply(m, function(x) update(x, "log(submit/n) ~ ."))

# Print latex table
regtab(c(m, m.log), digits=2, notes.width=1, keep.stat=c('n','rsq')
	, omit="nwins|hours|rating|nreg|nsub|ntop|risk|male|time|postgrad|below|paid|year"
	, add.lines=list(c("Room controls", rep(c("no controls", "selected", "full"), 2)))
	, dep.var.labels=c("Entry/n","log(Entry/n)")
	, covariate.labels=c("Tournament","Tournament w/reserve", "Room size (small)")
	, caption="Estimates of the effects of competition and room size on entry"
	, label='ols entry'
	, notes="The table reports OLS regression estimates of the effects of different competition styles on entry computed using three sets of room control variables: ``no controls\", ``selected\", and ``full.\" Standard errors are reported in parenthesis. ***,**, * indicate statistical significance at 1, 5, and 10 percent level.")

########################################
## @knitr entrySorting
########################################

# entrants <- subset(races, submit>0 & treatment!='reserve')
# t.test(rating ~ treatment=='tournament', data=entrants)
# t.test(log(hours+.00000001) ~ treatment, data=entrants)

# Switch to individual data
races$hours.imp <- impute(races$hours)
races$rating.imp <- impute(races$rating)
races$algo_rating[races$algo_rating==0] <- NA
races$algo_rating.imp <- impute(races$algo_rating)

summary(fit <- glm(submit ~ treatment + log(rating.imp) + hours.imp
								, data=races, family=binomial(logit)))
summary(step(fit))

summary(fit.interact <- glm(submit ~ treatment*(log(rating.imp) + hours.imp)
												, data=races))



races.100 <- expand.grid(treatment=levels(races$treatment)
													, rating.imp=seq(5, 30, l=100)
													, hours.imp=24)
summary(races.100)

races.100$yhat <- predict(fit.interact, newdata=races.100, type='response')
summary(races.100$yhat)

# Plot predictions
h <- 24
plot(yhat ~ rating.imp, data=subset(races.100,  hours.imp==h), pch=21, col='white', bg=races.100$treatment)
points(yhat ~ rating.imp, data=subset(races.100, treatment=='race' & hours.imp==h), col=2)
points(yhat ~ rating.imp, data=subset(races.100, treatment=='tournament' & hours.imp==h), col=3)
points(yhat ~ rating.imp, data=subset(races.100, treatment=='reserve' & hours.imp==h), col=4)








	
