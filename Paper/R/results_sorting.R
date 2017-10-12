################################################################################
# 
#	This script is for the analysis of sorting patterns
#
#
################################################################################

## @knitr sortingplots

# Functions  
create.grid <- function(x, l=100, ...) seq(from=min(x, ...), to=max(x, ...), length.out=l)

plot.prediction <- function(x, data, ...) {
	plot(formula=x, data=data, type='l', ...)
	lines(formula=update(x, '.+se.fit~.'), data=data, lty=2, ...)
	lines(formula=update(x, '.-se.fit~.'), data=data, lty=2, ...)
}

## Main program

fit <- lm(submit ~ log(rating) + hours, data=races)

rating.100 <- create.grid(races$rating, na.rm=TRUE)
dfp <- data.frame(hours=median(races$hours, na.rm=TRUE), rating=rating.100)
yhat <- predict(fit, newdata=dfp, se=TRUE)
out.rating <- cbind(dfp, yhat)

## HO?URS 
hours.100 <- create.grid(races$hours, na.rm=TRUE)
dfp.hours <- data.frame(hours=hours.100, rating=median(races$rating, na.rm=TRUE))
yhat <- predict(fit, newdata=dfp.hours, se=TRUE)
out.hours <- cbind(dfp.hours, yhat)

par(mfrow=c(2,2))
plot.prediction(fit ~ rating, out.rating, ylim=c(0, 1), xlab="Rating", ylab="Pr(entry | rating, hours)") 
title("Sorting based on skills\n(everyone)")
plot.prediction(fit ~ hours, out.hours, ylim=c(0, 1), xlab="Hours", ylab="Pr(entry | rating, hours)") 
title("Sorting based on hours\n(everyone)")

#####################
# Interactions rating
#####################

fit.int <- lm(submit ~ I(treatment=='tournament')*log(rating) + hours, data=races)

dfp$treatment <- 'race'
yhat <- predict(fit.int, newdata=dfp, se=TRUE)
out.rating.race <- cbind(dfp, yhat)

plot.prediction(fit ~ rating, out.rating.race, col='brown', ylim=c(0, 1), xlab="Rating", ylab="Pr(entry | rating, hours)") 
title("Sorting based on skills\n(races vs tournaments)")

dfp$treatment <- 'tournament'
yhat <- predict(fit.int, newdata=dfp, se=TRUE)
out.rating.tourn <- cbind(dfp, yhat)

lines(fit ~ rating, col='navy', data=out.rating.tourn, type='l')
lines(fit + se.fit ~ rating, col='navy', data=out.rating.tourn, type='l', lty=2)
lines(fit - se.fit ~ rating, col='navy', data=out.rating.tourn, type='l', lty=2)

#####################
# Interactions hours
####################

fit.int <- lm(submit ~ log(rating) + treatment*hours, data=races, subset=hours>0)

dfp.hours$treatment <- "race"
yhat <- predict(fit.int, newdata=dfp.hours, se=TRUE)
out.hours.race <- cbind(dfp.hours, yhat)

plot.prediction(fit ~ hours, out.hours.race, col='brown', ylim=c(0, 1), xlab="Hours", ylab="Pr(entry | rating, hours)") 
title("Sorting based on hours\n(races vs tournaments)")

dfp.hours$treatment <- "tournament"
yhat <- predict(fit.int, newdata=dfp.hours, se=TRUE)
out.hours.tourn <- cbind(dfp.hours, yhat)

lines(fit ~ hours, data=out.hours.tourn, col='navy', type='l')
lines(fit + se.fit ~ hours, data=out.hours.tourn, col='navy', type='l', lty=2)
lines(fit - se.fit ~ hours, data=out.hours.tourn, col='navy', type='l', lty=2)


################################################################################
################################################################################
################################################################################
################################################################################

## @knitr sortingtable

## Define functions ####

# Adjust model's formula by log-transforming dep var when necessary
adj.models <- function(x) {
	vars <- c('timezone','male','below30','postgrad','hours','hours12','hours34','hours56','hours78')
	for (i in vars) x <- gsub(paste('log\\(', i, "\\+1\\)", sep=''), i, x)
	vars <- c('nreg','paidyr', 'nwins','ntop5','ntop10','risk','rating','ratingsrm')
	for (i in vars) x <- gsub(paste(i, "\\+1", sep=''), i, x)
	return(x)
}

## Main program 

# Compute diff-in-diff estimator for effect of the treatment on the dep.var
contrast.default <- options('contrasts')
models <- adj.models(paste('log(',colnames(covars),"+1)", "~submit*treatment", sep=''))
models.fit <- sapply(models, function(x) lm(formula=x, data=cbind(covars, races)))

# Change contrast to estimate differences races vs tournaments 
races$treatment2 <- races$treatment
contrasts(races$treatment2) <- contr.sum(3, contrasts=TRUE)
models2 <- gsub("treatment","treatment2", models)
models.fit2 <- sapply(models2, function(x) lm(formula=x, data=cbind(covars, races)))


# Create table
table.sorting <- function() {
	get.star.string <- function(x) ifelse(x < 0.01, '***', ifelse(x<0.05, "**", ifelse(x<0.1,"*", "")))
	get.column <- function(varname, object, digits=2) {
		est <- sapply(object, function(x) coef(summary(x))[varname, 1])
		SE <- sapply(object, function(x) coef(summary(x))[varname, 2])
		pval <- sapply(object, function(x) coef(summary(x))[varname, 4])
		depvar <- as.vector(rbind(gsub("~.*","", names(est)), rep("", length(est))))
		stars <- get.star.string(pval)
		out <- as.vector(rbind(paste(format(round(est, digits)), stars, sep='')
			, paste("(",round(SE, digits),")", sep='')))
		data.frame(depvar, out)
	}
	x1 <- get.column('submitTRUE', models.fit2)
	x2 <- get.column('submitTRUE:treatmenttournament', models.fit)
	x3 <- get.column('submitTRUE:treatmentreserve', models.fit)
	x4 <- as.vector(rbind(sapply(models.fit, function(x) length(x$fitted)), rep("",length(models.fit))))
	cbind(x1, tournament=x2[,-1], reserve=x3[,-1], obs=x4)
}

# Create table
tab <- table.sorting()

# Keep some variables
i <- grep("rating|nreg|hours", tab$depvar)
tab <- tab[sort(c(i,i+1)), ]

colnames(tab) <- c('Variable'
	, "\\multicolumn{1}{L{2cm}}{Difference entrants vs non-entrants}"
	, "\\multicolumn{1}{L{2cm}}{Difference entrants in races vs tournaments}"
	, "\\multicolumn{1}{L{2cm}}{Difference entrants in races vs tournaments w/reserve}"
	, "Obs.")
xtab <- xtable(tab)
caption(xtab) <- 'Sorting patterns'
label(xtab) <- 'sorting table'
align(xtab) <- c("@{}l","@{}l", rep("c", ncol(tab)-1))
attributes(xtab)$notes <- " The table reports conditional mean differences of various competitors' characteristics conditional on entry and the randomly assigned competition style. Standard errors are reported in parenthesis. ***,**, * indicate statistical significance for t-test at 1, 5, and 10 percent level."

render.xtable(xtab
	, include.rownames=FALSE
	, sanitize.colnames.function=function(x)x
	, sanitize.text.function=function(x)gsub('-','$-$', x)
)










