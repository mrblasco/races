#####################
options(digits=3)
require(stargazer)
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
#####################




# Datasets
attach(races2)

# Descriptive plots ##########################################
pie(table(age))
pie(table(educ))
pie(table(gender))
pie(table(plang))

barplot(table(timezone), las=2, ho=T)
title("Timezone")

barplot(table(risk))
title("Rate your willingness to take risks in general\n from 1 'unwilling' to 10 'completely willing'")

pie(sort(table(country), dec=T), head(names(sort(table(country), dec=T)),10))
title("Country of origin")

boxplot(week1, week2, week3, week4, notch=T)
title("Looking ahead a week, how many hours do you forecast\n to be able to work on the solution of the problem?")
t.test(week1, week4) # wilcox.test(week1, week4)

# Participation #################################
tab <- table(submit, treatment)
fisher.test(tab[, c("race", "tournament")])
fisher.test(tab[, c("race", "tournament")], alternative='greater')

# Within large/small
tab <- table(submit, treatment, room_size)
fisher.test(tab[, c("race", "tournament"), "Small"], alternative='greater')
fisher.test(tab[, c("race", "tournament"), "Large"], alternative='greater')
	
# Races + reserve
tab <- table(submit, treatment=='tournament')
fisher.test(tab, alternative="greater")

tab <- table(submit, treatment=='tournament', room_size)
fisher.test(tab[,,"Small"], alternative="greater") # *
fisher.test(tab[,,"Large"], alternative="greater")

# Participation - regression #########################

# Impute missing values
risk_imp <- impute.random(risk)
mm_events <- impute.zero(mm_events)

fit <- rep()
fit$baseline <- glm(submit ~ 1, binomial)
fit$m1 <- update(fit$baseline, " ~ treatment")
fit$m2 <- update(fit$baseline, " ~ treatment + room_size")
fit$m3 <- update(fit$baseline, " ~ treatment*room_size")
fit$m4 <- update(fit$baseline, " ~ treatment + mm_events")
fit$m5 <- update(fit$baseline, " ~ treatment + factor(risk_imp)")
fit$m6 <- update(fit$baseline, " ~ treatment + mm_events + factor(risk_imp)")
fit$m7 <- update(fit$baseline, " ~ treatment + room_size + mm_events + factor(risk_imp)")
fit$m8 <- update(fit$baseline, " ~ treatment * room_size + mm_events + factor(risk_imp)")


stargazer(fit, type='text')


