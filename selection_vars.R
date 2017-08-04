#
#
#	Variable selection for Entry model
#
#

# Create dataset
races$n <- ave(races$submit, races$room_id, FUN=length)
d <- aggregate(submit ~ n + room_id + treatment + room_size, data=races, sum)
covars <- with(races, data.frame(year=2015-year, rating, nreg=nreg, nsub
						, algo_rating=algo_rating/100, algo_nreg, algo_nsub
						, lpaid=log(paid), nwins=nwins>0, ntop5=ntop5>0, ntop10=ntop10>0
						, risk, hours=hours, male, timezone.dist=abs(timezone+5)
						, postgrad=ifelse(educ=="Postgraduate (MA)" | educ=="Phd", 1,0)
						, below30=ifelse(age=="<20" | age=="20-25" | age=="26-30", 1, 0)))
controls <- aggregate(covars, by=with(races, list(room_id=room_id)), mean, na.rm=TRUE)
entry <- merge(d, controls)
entry$room_id<-NULL

# How many covariates
p <- ncol(controls)
2^p # prohibitively large number of possible model

# Fit linear model
entry.lm <- glm(log(submit/n) ~ treatment + room_size, data=entry)
summary(entry.lm)

# Add controls
entry.lm.all <- glm(log(submit/n) ~ . , data=entry)
entry.lm.step <- step(entry.lm.all, direction="both")
summary(entry.lm.all)
summary(entry.lm.step)

entry.lm <- entry.lm.step

# Prediction cost
cost <- function(y, mu=0) mean((y-mu)^2) # Mean squared error
muhat <- predict(entry.lm)
app.err <- cost(entry.lm$y, muhat) # 0.14

cv.err <- cv.glm(entry, entry.lm, K=6)
cv.err$delta

cv.err <- cv.glm(entry, entry.lm.all, K=6)
cv.err$delta

# Prediction function
entry.pred.fun <- function(data, i, formula) {
	d <- data[i, ]
	d.glm <- glm(formula, data=d)
	D.F.hatF <- cost(log(data$submit), predict(d.glm, data))
	D.hatF.hatF <- cost(log(d$submit), fitted(d.glm))
	c(log(data$submit)-predict(d.glm, data), D.F.hatF - D.hatF.hatF)
}
entry.boot <- boot(entry, entry.pred.fun, R=200, formula=formula(entry.lm))
n <- nrow(entry)
err.boot <- app.err + mean(entry.boot$t[,n+1]) # 0.19
err.boot

# Other measure of prediction error
err.632 <- 0
entry.boot$f <- boot.array(entry.boot)
for (i in 1:n) 
	err.632 <- err.632 + cost(entry.boot$t[entry.boot$f[,i]==0,i])/n
err.632 <- 0.368 * app.err + 0.632 * err.632

cbind(err.632, err.boot, app.err)

# Plot predictions
ord <- order(resid(entry.lm))
entry.pred <- as.vector(entry.boot$t[, ord])
entry.fac <- factor(rep(1:n, each=200), labels=ord)
plot(entry.fac, entry.pred, ylab='Prediction errors', xlab="Cases ordered by residual")

