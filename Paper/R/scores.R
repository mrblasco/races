# 
# Scripts for analysis of scores
# 
# 
# 

## @knitr scoresplot

boxplot.scores <- function(formula, data, ylim, ...) {
	h <- pretty(seq(ylim[1], ylim[2], length=5))
	colors <- c("brown", gray(0.75), gray(0.95))
 	boxplot(formula, data, col=colors, boxwex=0.5, frame=F, yaxt='n', xaxt="n", ylim=ylim, ...)
	abline(h=h, lty=3, col='lightgray')
 	boxplot(formula, data, col=colors, boxwex=0.5, frame=F, yaxt='n', xaxt="n", add=TRUE, ...)
	axis(2, at=h, h, col='lightgray', col.ticks='lightgray', las=2)
	axis(1, at=1:3, levels(final$treatment))
}


par(mfrow=c(1, 3)); ylim <- c(0.97, 1.04)
form <- formula(final.cens ~ treatment, ylim=ylim)
boxplot.scores(form, data=final, main="All rooms", ylim=ylim)
boxplot.scores(form, data=subset(final, room_size=='Small'), main="Small rooms\n(10 competitors)", ylim=ylim)
boxplot.scores(form, data=subset(final, room_size=='Large'), main="Large rooms\n(15 competitors)", ylim=ylim)


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
