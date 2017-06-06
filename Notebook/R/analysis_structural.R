#!/bin/env Rscript

# Prep
rm(list=ls())
require(xtable)
require(races)
attach(races)
tothours <- week1 + week2 + week3 + week4
paid <- impute(paid, 'zero')


#****************************************#
# Table "Outcomes by rooms" 
#****************************************#
room.data <- function() {
	m <- aggregate(submission ~ room + treatment, FUN=function(x) c(length(x), sum(x>0), sum(x)))
	dat <- data.frame(m[, 1:2], m[, 3])
	colnames(dat) <- c("room","treatment", "n", "participants", "submissions")
	avghours <- ave(tothours, paste(room, treatment), FUN=function(x) mean(x, na.rm=TRUE))
	avgskill <- ave(mm_rating, paste(room, treatment), FUN=function(x) mean(x, na.rm=TRUE))
	unrated  <- ave(is.na(mm_rating), paste(room, treatment), FUN=sum)
	totpaid  <- ave(paid, paste(room, treatment), FUN=sum, na.rm=TRUE)
	z <- data.frame(room, treatment, avgskill, avghours, unrated, totpaid)
	index <- tapply(1:nrow(z), paste(room, treatment), tail, n=1)
	m <- z[index, ]
	merge(dat, m)
}
dat <- room.data()
summary(dat)

#****************************************#
# A simple parametric model is that the count of participants in each room $i$ in a treatment $j$ has a Poisson distribution with mean $\mu_{ij} = \exp(\alpha + \beta_j)$. If all rooms are independent, then the total participants in each treatment are \sum_{i=1} \mu_{ij}. 
#****************************************#


# Modeling the count of participants per treatment
poi <- glm(participants ~ offset(log(n))+treatment+log(avgskill)+log(avghours)+log(totpaid), family=poisson(log), data=dat)
summary(poi)

ols <- glm(participants ~ treatment+log(avgskill)+log(avghours)+log(totpaid), family=gaussian(identity), data=dat, weights=n)
summary(ols)

nd <- data.frame(n=10)
yhat <- predict(poi,newdata=)
nsim <- 1e6
plot(table(rpois(nsim, lambda=yhat[1]))/nsim, type='l', ylab="Probability") # Race
lines(table(rpois(nsim, lambda=yhat[2]))/nsim, type='l', lty=2) # Tournament
lines(table(rpois(nsim, lambda=yhat[3]))/nsim, type='l', lty=3) # Reserve
legend("topright",levels(treatment), lty=1:3, lwd=2, bty='n')

#****************************************#
# "Survival" times for participants
#****************************************#
detach(races)

# Prep data
data(scores)
scores2 <- merge(subset(scores, submission==1), races, by='coder_id')
attach(scores2)

Start <- as.POSIXct("2015-03-08 12:00:00 EDT")
hourdf <- as.numeric(difftime(timestamp.x, Start, units='hours'))

# TABLE
dat <- cbind(mm_rating, treatment, hourdf)


#****************************************#
# A simple parametric model is the exponential where the mean 
# mu_{ij} = exp(alpha + beta x) (thus the link function is log)
# where x is the log(skill). Intercepts change in each group
# but the slope is constant (theory suggests slope changes)
#****************************************#

hourdf_l <- split(hourdf, treatment)
t.test(hourdf_l$race, hourdf_l$tournament) # ** 
kruskal.test(hourdf_l) # pval 

fit <- glm(hourdf ~ treatment*log(mm_rating), gaussian)
summary(fit)
anova(fit, test='Chisq')

par(mfrow=c(1, 2))
pch <- as.character(as.numeric(treatment))
plot(hourdf ~ mm_rating, pch=pch, ylab="Time of first submission (hours)", xlab="Skill rating")
x.20 <- seq(600, 3000, length=20)
sapply(1:3, function(i) {
	yhat <- predict(fit, data.frame(mm_rating=x.20, treatment=levels(treatment)[i], year=levels(year)[1]))
	lines(x.20, yhat, lty=i) # Race
})

with(hourdf_l, qqplot(race,tournament, pch=16, xlab="Quantile of race distribution", ylab="Quantile of tournament distribution"))
abline(a=0, b=1)

fig.cap <- "Summary plot for fits of an OLS model fitted to the three treatment groups of first submission time for participants. The left panel shows the times and the fitted mean as a function of their skill rating (race: group 1, solid; tournament: group 2, dashed; reserve: group 2, dotted). The right panel shows Q-Q plot of the distribution of time between race and tournament."


## Structural estimation
# Assumptions:
# 	1) Alpha = 1 
# 	2) gamma(x)C = exp(a -x * b)

## Equations:
# (1) Pr(entry) = Pr(x >= threshold) = 1 - F(threshold)
# (2) Zero profit ==> F(threshold)^(n-1) = gamma(threshold) C
# Assumptions + (1) + (2) ==>
# (3) 1 - exp(a - x * b)^(1/(n-1))


# Assumption suppose we know the distribution of skills
dskill <- function(x, ...) dbeta(x, shape1=1.5, shape2=2, ...)
pskill <- function(x, ...) pbeta(x, shape1=1.5, shape2=2, ...)
rskill <- function(x, ...) rbeta(x, shape1=1.5, shape2=2, ...)
qskill <- function(x, ...) qbeta(x, shape1=1.5, shape2=2, ...)

# Prob(entry)
n <- 10 # This is m-1
p <- tapply(submit, treatment, mean)
theta <- qskill(p, lower.tail=FALSE) 
theta # Ability thresholds

# Zero profit condition
alpha <- -1
pskill(theta)^(n) - theta^alpha * K

# This gives exponent of cost function with respect to ability




# Response function
response.fun <- function(p, x, n) {
  	zero <- .Machine$double.eps
	one <- 1 - zero
	if (length(p)!=2) stop("Parameter vector `p` must be of length 2")
	if (n < 2) stop("Competitors `n` must be greater than or equal to 2")
	eta <- (p[1] + x * p[2]) * (1 / (n - 1))
	prb <- 1 - exp(-eta)
	prb[prb < 0] <- zero
	prb[prb > 1] <- one
	prb
}

# Log likelihood
loglik <- function(p, x, y, n) {
  fv <- response.fun(p, x, n) 
  -sum(dbinom(y, 1, fv, log=TRUE))
}

# Example
ncomp <- 6
n <- 300
p  <- c(4, -0.5)
x <- rbinom(n, 1, 0.5) #rnorm(n)
y <- rbinom(length(x), 1, response.fun(p, x, ncomp))
sol <- nlm(loglik, p=c(-10, 0.1), x=x, y=y, n=ncomp)
sol

# Test consistency / biased
replicate(1e3, {
	y <- rbinom(length(x), 1, response.fun(p, x, ncomp))
 	p.start <- 1- exp( - coef(glm(y ~ x)) * (1 / (ncomp - 1)))
	sol <- nlm(loglik, p=p.start, x=x, y=y, n=ncomp)
	sol$estimate
}) -> est

boxplot(t(est))
points(1:2, p, col=2, pch=16)


# Prepare data
ncomp <- ifelse(races$room_size=='Large', 15, 10)
x <- ifelse(races$treatment=='tournament', 1, 0)
y <- ifelse(races$submit==1, 1, 0)


p.start <- 1- exp( - coef(glm(y ~ x)) * mean((1 / (ncomp - 1))))
sol <- nlm(loglik, p=p.start, x=x, y=y, n=ncomp)
sol

# bootstrap
obs <- length(y)
replicate(999, {
	index <- sample(obs, replace=TRUE)
	x.boot <- x[index]
	y.boot <- y[index]
	ncomp.boot <- ncomp[index]
	mu <- mean((1 / (ncomp.boot - 1)))
	p.start <- 1- exp( - coef(glm(y.boot ~ x.boot)) * mu)
	sol <- nlm(loglik, p=p.start, x=x.boot, y=y.boot, n=ncomp.boot)	
	sol$estimate
}) -> est

boxplot(t(est))
abline(h=0, col=2)











