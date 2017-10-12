## @knitr sorting
## This script tests the extent of ability-based sorting
## and differences across treatments.
set.seed(4881)

# Data preparation: we first impute missing values at random
races$rating.imp <- impute(races$rating, "random")
races$algo_rating[races$algo_rating==0] <- NA # Zero algo rating means missing
races$algo_rating.imp <- impute(races$algo_rating, "random")/1e3
races$hours[races$hours==0] <- NA # Zero hours does not mean anything
races$hours.imp <- impute(races$hours, "random")

# Sorting: we use linear regression to estimate the probability of entry 
# as a function of our ability measures.
submit.logit <- rep()
submit.logit$m1 <- glm(submit ~ log(rating.imp), data=races, quasibinomial)
submit.logit$m2 <- glm(submit ~ log(hours.imp), data=races, quasibinomial)
submit.logit$m3 <- glm(submit ~ log(algo_rating.imp), data=races, quasibinomial)
submit.logit$m123 <- glm(submit ~ log(rating.imp) + log(hours.imp) + algo_rating.imp, data=races, quasibinomial)

# ... checking for differences with the regression with no missing values
submit.logit$nomiss <- glm(submit ~ log(rating) + log(hours) + log(algo_rating), data=races, quasibinomial)

# Results show significant and strong association between ratings, hours, but not algo rating 
# (that are broadly consistent between models with and without the imputed values). 
# A competitor's ability is hence an important determinant of entry, as expected. 
stargazer(submit.logit, type='text', digits=2)

# To estimate differences across treatments, we use non-parametric regression which generally provides a better fit and appears ---in our setting--- less sensitive to extreme values of covariates than conventional multiple regression. Given our set of competitor characteristics is orthogonal to treatment assignment, the (non-parametric) estimated conditional probability of entry given ability and treatment assignment is correctly identified. Conventional statistical inference, however, might be biased because of correlations within rooms.	

# We use the simplest approach: local constant (Nadaraya-Watson) with least-squares cross-validation bandwidth selection method.
submit.np <- npreg(as.numeric(submit) ~ rating.imp + hours.imp + treatment, data=races)
summary(submit.np)

# We also override the default local constant (Nadaraya-Watson) with "local linear" regression 
# which gives essentially the OLS results. 
submit.np.ll <- npreg(as.numeric(submit) ~ rating.imp + hours.imp + treatment, data=races, regtype='ll', nmulti=5)
summary(submit.np.ll) # Results are not good! So, we drop it.

# We also look at single index models (Ichimura) fitting  Y = G(XBeta) + epsilon
# where $G(\cdot)$ is non-parametric function in the index XB. 
submit.index <- npindexbw(as.numeric(submit) ~ rating.imp + hours.imp + treatment, data=races
							, method='ichimura', nmulti=5) # try changing optim.methods (too slow)
summary(submit.index) # Results are not 

# ... and OLS for comparison purposes
submit.lm <- lm(as.numeric(submit) ~ (rating.imp + hours.imp)*treatment, data=races)
summary(submit.lm)

# Plot the results

# Set color variables
color.treatments <- adjustcolor(c("navy", "brown", "orange"), alpha.f = 0.5)
pch.treatments <- c(15, 17, 19)
	
# Create new data for predictions 
rating.eval <- seq(min(races$rating.imp), max(races$rating.imp), length=50)
nd <- expand.grid(treatment=levels(races$treatment), rating.imp=rating.eval, hours.imp=25)

nd$yhat.np <- predict(submit.np, newdata=nd)
nd$yhat.np.ll <- predict(submit.np.ll, newdata=nd)
nd$yhat.lm <- predict(submit.lm, newdata=nd)
# nd$yhat.index <- predict(submit.index, newdata=nd)

# Do the same for available hours of work 
hours.eval <- seq(min(races$hours.imp), 90, length=50)
nd.hours <- expand.grid(treatment=levels(races$treatment), rating.imp=12, hours.imp=hours.eval)
nd.hours$yhat.np <- predict(submit.np, newdata=nd.hours)
nd.hours$yhat.lm <- predict(submit.lm, newdata=nd.hours)

# Plot the results in 1x2 grid
par(mfrow=c(1, 2))
index <- as.numeric(nd$treatment)
plot(yhat.np ~ rating.imp, data=nd
		, pch=pch.treatments[index], col=color.treatments[index], ann=FALSE)
legend('topleft', legend=levels(nd$treatment), pch=pch.treatments, col=color.treatments, bty='n')
title(xlab="skill rating (MMs)", ylab="probability"
	, main=expression(paste("Pr(entry | treatment, skills,", bar("hours"),")")))
rug(races$rating.imp)

plot(yhat.np ~ hours.imp, data=nd.hours
		, pch=pch.treatments[index], col=color.treatments[index], ann=FALSE)
legend('topleft', legend=levels(nd$treatment), pch=pch.treatments, col=color.treatments, bty='n')
title(xlab="hours", ylab="probability"
	, main=expression(paste("Pr(entry | treatment, hours,", bar("skills"),")")))
rug(races$hours.imp)

# Alternative models
# plot(yhat.np.ll ~ rating.imp, data=nd, pch=pch.treatments[index], col=color.treatments[index])
# legend('top', legend=levels(nd$treatment), pch=pch.treatments, col=color.treatments, bty='n')
# plot(yhat.index ~ rating.imp, data=nd, pch=pch.treatments[index], col=color.treatments[index])
# legend('top', legend=levels(nd$treatment), pch=pch.treatments, col=color.treatments, bty='n')
# plot(yhat.lm ~ rating.imp, data=nd, pch=pch.treatments[index], col=color.treatments[index])
# legend('top', legend=levels(nd$treatment), pch=pch.treatments, col=color.treatments, bty='n')
# plot(yhat.lm ~ hours.imp, data=nd.hours, pch=pch.treatments[index], col=color.treatments[index])
# legend('top', legend=levels(nd$treatment), pch=pch.treatments, col=color.treatments, bty='n')
# 




