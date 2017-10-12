################################################################################
# 
#	Scripts for data section of Tournaments vs Races 
# ablasco@fas.harvard.edu
# 
################################################################################ 

## @knitr experimental_design_table

x <- expand.grid(size=c("Large", "Small")
								, treatment=c("Race", "Tournament", "Tournament w/reserve"))
x$num <- ifelse(x$size=='Large', 15, 10) * 4
tab <- xtabs(num ~ treatment + size, data=x)
rownames(tab) <- capitalize(rownames(tab))
xtab <- xtable(addmargins(tab), digits=0)
caption(xtab) <- "Experimental Design"
label(xtab) <-  "experiment table"
align(xtab) <- c("@{}l", rep("r", ncol(xtab)))
render.xtable(xtab)



## @knitr descriptive_table

tab <- descriptives(covars)
xtab <- xtable(tab)
digits(xtab) <- c(1, 1, rep(0, ncol(xtab)-2), 3)
align(xtab) <- c("@{}l", rep("r", ncol(xtab)))
caption(xtab) <- "Descriptive statistics"
label(xtab) <- "summary"
attributes(xtab)$notes <- "Platform data: `year` denotes the years as platform member; `nreg` and `nregsrm` are the counts of registrations to past MMs and SRMs competitions, respectively; `nsub` and `nsubsrm` are the counts of submissions to past MMs and SRMs competitions, respectively; `paidyr` is prize money per year (in thousand of dollars) won in past competitions; `nwins`, `ntop5`, `ntop10` denote placements in past MMs competitions; Registration survey: `risk` is a measure of risk aversion; `hours` anticipated hours of work on solving the problem of the contest; `male` indicates the gender; `timezone` refers to competitor's residence during the contest; `postgrad` is an indicator for post-graduate educational degree (MAs or PhDs); and `below30` indicates age below 30 years old."
add <- list()
add$cmd <- c('\\multicolumn{1}{@{}l}{\\emph{Platform data:}}\\\\\n'
						, '\\\\[-1.86ex]\\hline\\multicolumn{1}{@{}l}{\\emph{Survey data:}}\\\\\n'
						, rep('\\\\[-1.86ex]~', nrow(tab)))
add$pos <- c(0, 9, 0:(nrow(tab)-1))
render.xtable(xtab, add)


## @knitr rating_density_comparison_figure

rating_pdf <- with(subset(races, !is.na(rating)), tapply(rating, treatment, density))
algo_rating_pdf <- with(subset(races, algo_rating>0), tapply(algo_rating/100, treatment, density))
rating.lm <- lm(rating ~ algo_rating, data=races, subset=algo_rating>0)

par(mfrow=c(1,3))
colors <- c("brown", gray(.75), gray(.85))
plot(NA, NA, xlim=c(0, 35), ylim=c(0, .1), xlab="Skill rating (MMs)", ylab='Density')
title("Problem solving")
for (i in 1:3) lines(rating_pdf[[i]], lty=i, lwd=2)

plot(NA, NA, xlim=c(0, 35), ylim=c(0, .1), xlab="Skill rating (SRMs)", ylab='Density')
title("Programming speed")
for (i in 1:3) lines(algo_rating_pdf[[i]], lty=i, lwd=2)

with(subset(races, algo_rating>0), 
	plot(algo_rating, rating, xlab="Skill rating (SRMs)", ylab="Skill rating (MMs)"))
abline(rating.lm, col=2, lwd=2)
