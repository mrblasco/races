
impute.random <- function(x) {
	miss <- is.na(x)
	x[miss] <- sample(x, size=sum(miss), replace=TRUE)
	return(x)
}

attach(races)
tothours <- week1 + week2 + week3 + week4
tothours.imp <- impute.random(tothours)
age.imp <- impute.random(age)

dat <- na.omit(data.frame(submit, treatment, mm_rating, tothours.imp))
binom <- glm(submit ~ treatment+log(mm_rating)+log(tothours.imp), data=dat, binomial)
pred <- predict(binom, type = "response")

# Plot predictions
plot(pred, jitter(binom$y), col=ifelse(pred>0.5,'red','blue'))
curve(ifelse(x>0.5, 1, 0), add=TRUE, lty=2)

# Bootstrap
n <- length(pred)
nboot <- 999
coef.boot <- replicate(nboot, {
	submit.star <- rbinom(n, 1, pred)
	binom.star <- update(binom, "submit.star ~ .", data=data.frame(submit.star, dat))
	coef(binom.star)
	})

par(mar=c(3,8,3,2))
boxplot(t(coef.boot[-1, ]), horizontal=TRUE, las=1)
abline(v=0,col=2)
title('Parametric bootstrap')