#####################
options(digits=3)
require(stargazer)
require(arm)


#----------------------------------------#
#	Helper functions					 #
#----------------------------------------#
ilogit <- function(x) exp(x)/(1+exp(x)) 
impute.random <- function(x) {
	miss <- is.na(x)
	x[miss] <- sample(x[!miss], size=sum(miss), replace=TRUE)
	return(x)
}
impute.zero <- function(x) {
	miss <- is.na(x)
	x[miss] <- 0
	return(x)
}
censoring <- function(x, value, top=TRUE) {
	if (top) return(ifelse(x>value, value, x))
	else return(ifelse(x<value, value, x))
}

plot.fit <- function(x, ...) {
	yhat <- predict(x)
	plot(jitter(yhat), jitter(x$y), pch=16
		, col=ifelse(yhat>0.5,"red","blue")
		, ...)
	curve(ilogit, add=TRUE)
	abline(h=c(0,1), lty=2, col=gray(.9))
}

#----------------------------------------#
#	Impute / new variables				 #
#----------------------------------------#

races$room_id <- as.numeric(races$room) + 10*as.numeric(races$treatment)
races$risk_imp <- impute.random(races$risk) # Impute missing values at random
races$mm_events.top <- censoring(races$mm_events, 50)
races$mm_entry <- races$mm_events / races$mm_reg
races$tot_hours <- with(races, week1 + week2+week3+week4)
races$member_year  <- as.numeric(format(races$member_date,'%Y'))
races$member_year.bottom  <- censoring(races$member_year, 2005, top=FALSE)

#----------------------------------------#
#	Analysis							 #
#----------------------------------------#
attach(races)

# Testing differences in participation
tab <- table(submit, treatment)
ft.overall <- fisher.test(tab) 
ft.race <- fisher.test(tab[, c("race", "tournament")])
ft.race.gr <- fisher.test(tab[, c("race", "tournament")], alternative='greater')


# Testing differences in participation across large/small rooms
tab <- table(submit, room_size)
ft.room.size <- fisher.test(tab)

# Testing differences in participation race | large/small rooms
tab <- table(submit, treatment, room_size)
ft.small.gr <- fisher.test(tab[, c("race", "tournament"), "Small"], alternative='greater')
ft.large.gr <- fisher.test(tab[, c("race", "tournament"), "Large"], alternative='greater')

# Testing differences using races+reserve vs tournament
tab <- table(submit, treatment=='tournament')
ft.combine.gr <- fisher.test(tab, alternative="greater")

# Testing differences using races+reserve
tab <- table(submit, treatment=='tournament', room_size)
tab.combine.large.gr <- fisher.test(tab[,,"Small"], alternative="greater") # 10%
tab.combine.large.gr <- fisher.test(tab[,,"Large"], alternative="greater")

# Overall, we find no differences using fisher test both in two-sided or one-sided tests.
# Direction seems consistent with theory. Lack of statistical power may limit our ability to detect small effects (i.e., effects below xxx). 


#----------------------------------------#
#	Regression analysis					 #
#----------------------------------------#

add.controls <- function(x) paste(x, "educ + gender + age + plang + timezone", sep='+')

fit <- rep()
fit$m0 <- glm(submit ~ 1, binomial)
fit$m1 <- update(fit$m0, " ~ treatment")
fit$m2 <- update(fit$m0, " ~ treatment + room_size")
fit$m2c <- update(fit$m0, add.controls(" ~ treatment + room_size"))
fit$m3 <- update(fit$m0, " ~ treatment + mm_events.top")
fit$m5 <- update(fit$m0, " ~ treatment + risk_imp")
fit$m6 <- update(fit$m0, " ~ treatment + mm_events.top + risk_imp")
fit$m7 <- update(fit$m0, " ~ treatment + room_size + mm_events.top + risk_imp")
fit$m7c <- update(fit$m0, add.controls(" ~ treatment + room_size + mm_events.top + risk_imp"))


controls_yes <- sapply(fit, function(x) ifelse(any(grepl("educ", names(coef(x)))), "Yes","No"))

stargazer(fit, type='text', digits=2, omit='age|plang|educ|gender|timezone', add.lines=list(c("Controls",controls_yes)))
 
# Plot
par(mfrow=c(4,4), mar=c(2,2,1,1))
sapply(fit, plot.fit, xlim=c(-5, 5))


# Regression by treatment?
fit <- rep()
fit$m0 <- glm(add.controls("submit ~ room_size + mm_events + risk_imp + paid"), binomial)
fit$m0.race <- update(fit$m0,  subset=treatment=='race')
fit$m0.tourn <- update(fit$m0, subset=treatment=='tournament')
fit$m0.reserve <- update(fit$m0, subset=treatment=='reserve')

controls_yes <- sapply(fit, function(x) ifelse(any(grepl("educ", names(coef(x)))), "Yes","No"))

stargazer(fit, type='text', digits=3, omit='age|plang|educ|gender|timezone', add.lines=list(c("Controls",controls_yes)))


# Need bayesian adjustment
rac <- subset(races, treatment=='race')
tou <- subset(races, treatment=='tournament')
res <- subset(races, treatment=='reserve')

controls <- "age + educ + gender + timezone"
predictors <- "tot_hours + mm_events.top + mm_entry + risk_imp + factor(member_year.bottom)"
model 	<- as.formula(paste("submit ~", predictors,"+",controls))

fit <- rep()
fit$rac <- bayesglm(model, family=binomial, data=rac)
fit$tou <- bayesglm(model, family=binomial, data=tou)
fit$res <- bayesglm(model, family=binomial, data=res)

summary(fit$rac) 
summary(fit$tou)
summary(fit$res)

# Plot
par(mfrow=c(1, 3), mar=c(2,2,1,1))
sapply(fit, plot.fit, xlim=c(-5, 5))


# Do week hours predict participation?
fit <- rep()
fit$m1 <- glm(submit ~ week1+week2+week3+week4, family=binomial)
fit$m2 <- glm(submit ~ tot_hours, family=binomial)
fit$m3 <- glm(submit ~ tot_hours + mm_events.top, family=binomial)
fit$m3 <- glm(submit ~ tot_hours + mm_events.top + mm_entry, family=binomial)

stargazer(fit, type='text', digits=3)




