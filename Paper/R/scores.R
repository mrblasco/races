# 
# Scripts for analysis of scores
# 
# 
# 

## @knitr scores_boxplot
	
# Set color variables
color.treatments <- adjustcolor(c("navy", "brown", "orange"), alpha.f = 0.5)
pch.treatments <- c(15, 17, 19)
	
# Subsetting datasets by room size
final.large <- subset(final, room_size=='Large')
final.small <- subset(final, room_size=='Small')

par(mfrow=c(1, 3))
ylim <- c(0.97, 1.04)
model <- final.cens ~ treatment
boxplot(model, data=final, col=color.treatments, ann=FALSE, ylim=ylim)
title(main="All rooms", ylab='Highest room score')
boxplot(model, data=final.small, col=color.treatments, ann=FALSE, ylim=ylim)
title(main=paste("Small rooms\n(10 competitors per room)", sep='')
	, ylab='Highest room score')
boxplot(model, data=final.large, col=color.treatments, ann=FALSE, ylim=ylim)
title(main=paste("Large rooms\n(15 competitors per room)", sep='')
	, ylab='Highest room score')


## @knitr scorestable

m <- rep()
m$final.lm <- lm(100*final.cens ~ treatment + room_size, data=final)
m$final.lm.partial <- update(m$final.lm, ~ . + nwins + ntop10 + timezone + postgrad + male)
m$final.lm.full <- lm(100*final.cens ~ . -hours12-hours34-hours56-hours78-final, data=final[,-1])
m.log <- lapply(m, function(x) update(x, "log(100*final.cens) ~ .")) 

regtab(c(m, m.log), digits=2, notes.width=1, keep.stat=c('n','rsq')
	, omit="nwins|hours|rating|nreg|nsub|ntop|risk|male|time|postgrad|below|paid|year"
	, add.lines=list(c("Room controls", rep(c("no controls", "partial", "full"), 2)))
	, dep.var.labels=c("Highest score","log(Highest score)")
	, covariate.labels=c("Tournament","Tournament w/reserve", "Room size (small)")
	, notes="The table reports regression estimates of the effects of different competition and room size on the highest score in a room computed using three sets of room controls: ``no controls\", ``partial\", ``fulla.\" Standard errors are reported in parenthesis. ***,**, * indicate statistical significance at 1, 5, and 10 percent level."
	, caption="Estimates of the Effect of Competition Style on Performance"
	, label='scores table')
