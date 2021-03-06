
Results
=======

```{r results}
options("digits"=3)
# submissions <- tapply(races.sub$id, races.sub$handle, max)
submissions <- 1:100
pp <- 1:4
nsub <- 1:4
ns <- 12
kt <- 12
# nsub <- nrow(races.sub) # Number of submissions
nsub.med <- median(submissions)
nsub.max <- max(submissions)
nsub.min <- min(submissions)
npart <- sum(races$submit) # Number of participants

p.part <- round(100*tapply(races$submit, races$treatment, mean))
tab <- table(races$submit, races$treatment)
ft <- fisher.test(tab)
``` 

In the eight-day submission period, we collected a total of `r nsub` submissions  made by  `r npart` competing participants, with a median of `r nsub.med` submissions per person (between a minimum of `r nsub.min` and a maximum of `r nsub.max` submissions).  The response rate was higher in the Tournament group (`r p.part["Tournament"]` percent), followed by the Tournament w/reseve (`r p.part["Reserve"]` percent), and the Race treatment (`r p.part["Race"]` percent). This is consistent with our prediction [xxxxx], although these differences were not statistically significant (a `r ft$method` gives a p-value of `r ft$p.value`). 



```{r, fig.width=5, fig.height=7, fig.cap="Participation rates by rooms"}
# races$room_size <- ave(as.numeric(races$handle), races$room, FUN=length)
# part <- aggregate(submit ~ treatment + room + room_size, sum, data=races)
# part.l <- split(part, part$treatment)
# par(mfrow=c(3, 1), mar=c(3, 3, 3, 1))
# for (i in 1:3) {
#   x <- part.l[[i]]
#   p <- (x$submit + 1) / (x$room_size + 2)
#   SE <- sqrt(p * (1-p) / x$room_size)
#   x.title <- names(part.l)[i]
#   plot(p, 1:length(p), xlim=c(0, 1), pch=16, main=x.title)
#   segments(x0=p+SE, x1=p-SE, y0=1:length(p))
#   abline(v=(sum(x$submit) + 1) / (sum(x$room_size)+2))
# }
```

Figure xxx shows the participation rates by rooms.

```{r}
# races$submit2 <- races$handle %in% unique(subset(races.sub,  system>=800000)$handle)
# pp <- 100*tapply(races$submit2, races$treatment, mean)
# (tab <- table(races$submit2, races$treatment))
# ft <- fisher.test(tab)
```


Similar results are found when we consider only those who made submissions above a score of xxxx. Participation across treatments was higher in the Tournament treatment (`r pp["Tournament"]` percent), followed by the Tournament w/reseve (`r pp["Reserve"]` percent), and the Race treatment (`r pp["Race"]` percent). However,  these differences are not statistically significant (using a `r ft$method` gives a p-value of `r ft$p.value`)

```{r}
# races$nsub <- NA
# index <- match(races$handle, names(submissions))
# races$nsub <- as.numeric(submissions[index])
# print(ns <- tapply(races$nsub, races$treatment, FUN=median, na.rm=T))
# kt <- kruskal.test(split(races$nsub, races$treatment))
```

Regarding to the frequency of submissions per participant, the median count is larger in the race and in the tournament w/reserve (`r ns["Race"]` and `r ns["Reserve"]` respectively) compared to the Tournament (a median of `r ns["Tournament"]` submissions). However, a `r kt$method` fails to reject the null hypothesis (p=`r kt$p.value`) that at least one treatment was different in the location of the frequency distribution of the submissions. 


```{r}
# score.final <- tapply(races.sub$provision, races.sub$handle, tail, n=1)
# races$score.final <- NA
# index <- match(races$handle, names(score.final))
# races$score.final <- as.numeric(score.final[index])
# 
# print(ms <- tapply(races$score.final, races$treatment, FUN=median, na.rm=T)/1e6)
# kt <- kruskal.test(split(races$score.final, races$treatment))
```

Concerning the distribution of the scores on the last submission, the median final scores was higher in the Tournament w/reserve treatment (`r ms["Reserve"]`), followed by the Tournament  (`r ms["Tournament"]`), and the Race treatment (`r ms["Race"]`). As before, however, these differences are not statistically significant (a `r kt$method` gives a p-value of `r kt$p.val`).

```{r}
# first_submission <- min(races.sub$timestamp)
# last_submission <- max(races.sub$timestamp)
# mins_from_1st <- as.numeric(difftime(races.sub$timestamp, first_submission, units='mins'))
# mins_from_last <- as.numeric(difftime(races.sub$timestamp, last_submission, units='mins'))

#tapply(mins_from_1st/60, races.sub$handle, FUN=min)
#tapply(mins_from_last/60, races.sub$handle, FUN=min)
```

Finally, let us focus on the timing of the first and last submission. xxxx

```{r, fig.cap="Submissions timing within the submission period"}
# normalize <- function(x) (x - min(x))  / diff(range(x))
# timing <- normalize(as.numeric(races.sub$timestamp))
# index <- match(races.sub$handle, races$handle)
# timing.l <- split(timing, races$treatment[index])
# par(mfrow=c(1, 3))
# sapply(1:3, function(x) hist(timing.l[[x]], main=names(timing.l)[x], ylim=c(0, 200))) -> z
```

Here we consider the hours of the day on the 24h. We normalize the 24h on the unit interval (here I think we should take into account the different timezoes.)

```{r, fig.cap="Submissions within the 24h (need to adjust for timezone)"}
# hours <- as.numeric(format(races.sub$timestamp, '%H'))
# index <- match(races.sub$handle, races$handle)
# hours.l <- split(hours, races$treatment[index])
# par(mfrow=c(1, 3))
# for (i in 1:3) {
#   x <- hours.l[[i]]
#   x.title <- names(hours.l)[i]
#   hist(x, ylim=c(0, 120), xlim=c(0, 24), main=x.title, xlab="Day hours")
# }
```


Regressions
------------


Although we do not find  significant differences through an univariate analysis, it is possible that differences will be xxx in a multivariate analysis. Adding controls can indeed reduce noise and improve precisions of our estimates. 

Let's consider first a simple logistic model

```{r}
fit <- rep()

# Baseline mode
fit$base <- glm(submit ~ treatment, data=races, quasibinomial)
summary(fit$base) ## Approx 

# Add demographic controls
fit$m1 <- update(fit$base, "submit ~ treatment + gender + educ + age + timezone + plang")
summary(fit$m1) ## Approx 

# Add platform controls
fit$m2 <- update(fit$base, "submit ~ treatment + algorating  + mmevents + algoevents + totalpayments")
summary(fit$m2) ## Approx 

# Everything
fit$m3 <- update(fit$base, "submit ~ treatment + algorating  + mmevents + algoevents + totalpayments + gender + educ + age + timezone + plang")
summary(fit$m3)
```

```{r}
races$mmrating[is.na(races$mmrating)]<-0

fit <- rep()
fit$m1 <- glm(submit ~ poly(mmevents, deg=3), data=races, family='binomial')
fit$m2 <- glm(submit ~ poly(mmevents, deg=2) + poly(mmrating, deg=2), data=races, family='binomial')
stargazer(fit, type='text')

anova(fit$m2, test="Chisq") 

best.model <- fit$m2
plot(jitter(ifelse(races$submit, 1, 0)) ~ predict(best.model), pch=4, yaxt="n", col=ifelse(predict(best.model)>0, 2, 1))
points(ilogit(predict(best.model)) ~  predict(best.model), pch=16)
abline(h=c(0,1))
```

This result does not seem to correlate well with the competitor's experience or skills, as the Pearsons's correlation coefficient between the count of past competitions or the rating and the count of submissions is positive but generally low; see Table XXX. Thus, differences in submissions appear idiosyncratic and perhaps related to the way to organize the work rather than systematically associated with underlying differences in experience or skills.

```{r}
#cor(dat[, c("nsub", "mm.rating", "mm.count")], use='pairwise.complete.obs')
```

The timing of submissions was rather uniform during the submission period with a peak of submissions made in the last of the competition. (explain more) 

```
#scores$submax <- ave(races.sub$id, races.sub$handle, FUN=max)
#par(mfrow=c(2, 1), mar=c(4,4,2,2))
#plot(subid==1 ~ as.POSIXct(subts), data=scores, type='h', yaxt='n'
#    , xlab='', ylab='', main='Dispersion time first submission')
#plot(subid==submax ~ as.POSIXct(subts), data=scores, type='h'
#    , yaxt='n', xlab='', ylab='', main='Dispersion time last submission')
```

Proportions by rooms.
```
nsub <- tapply(races.sub$id, races.sub$handle, length)
races$submit <- races$handle %in% names(nsub)
treat <- tapply(races$treatment, races$room, unique)
n1 <- tapply(races$submit, races$room, sum)
n <- tapply(races$submit, races$room, length)
p <- (n1 + 1) / (n + 2)
SE <- sqrt(p*(1-p) / (n+2))
CI <- cbind(p+1.96*SE, p - 1.96*SE)

# All rooms
plot(p, 1:length(p), xlim=c(-0.1, 1), yaxt='n', bty='n', ann=FALSE, col=treat, pch=16)
segments(y0=1:length(p), x0=p+SE, x1=p-SE, col=treat, lwd=3)
segments(y0=1:length(p), x0=CI[, 1], x1=CI[, 2], col=treat)
text(y=1:length(p), x=p, levels(races$treatment)[treat], pos=3, cex=0.5, xpd=TRUE)
abline(v=mean(races$submit))

# Large rooms
treat <- treat[n<15]
p <- p[n<15]
n <- n[n<15] 
SE <- sqrt(p*(1-p) / (n+2))
CI <- cbind(p+1.96*SE, p - 1.96*SE)
plot(p, 1:length(p), xlim=c(-0.1, 1), yaxt='n', bty='n', ann=FALSE, col=treat, pch=16)
segments(y0=1:length(p), x0=p+SE, x1=p-SE, col=treat, lwd=3)
segments(y0=1:length(p), x0=CI[, 1], x1=CI[, 2], col=treat)
text(y=1:length(p), x=p, levels(races$treatment)[treat], pos=3, cex=0.5, xpd=TRUE)
abline(v=mean(races$submit))


```




Consider panel data!

```{r}
day <- as.numeric(format(races.sub$timestamp, '%d'))
races.sub$day <- cut(day, c(8,10,12,14, 16), include.lowest=T, right=FALSE)
subs.long0 <- expand.grid(handle=unique(races.sub$handle), day=levels(races.sub$day))
subs.long1 <- aggregate(id ~ day + handle, data=races.sub, FUN=length)
subs.long <- merge(subs.long0, subs.long1, by=c("handle", "day"), all.x=TRUE)
subs.long$id[is.na(subs.long$id)] <- 0
plot(subs.long[, -1])
summary(glm(id ~ day, data=subs.long))
summary(glm(id ~ day, data=subs.long, family=quasipoisson))
summary(glm(id>0 ~ day, data=subs.long))
```

Scores:  xxxx
 



Treatment differences
------------------------

Difference in participation by treatments are show in Table XX. 

```{r, results='asis'}
races$submit <- races$handle %in% races.sub$handle
tab <- table(races$treatment, races$submit)
fisher.test(tab)
# xtable(addmargins(tab, FUN=Total), digits=0)
```

We find no differences in the room size. 

```{r, results='asis'}
tab <- table(races$room_type, races$submit)
fisher.test(tab)
#xtable(addmargins(tab, FUN=Total), digits=0)
```

Ex-post

```{r}
#boxplot(races$lastscore ~ races$treatment, outline=FALSE, notch=TRUE)
#scores.by.room <- with(dat, tapply(lastscore, room, max, na.rm=TRUE))
#plot(sort(scores.by.room), pch='.')
#text(sort(scores.by.room), gsub("Group ", "",names(scores.by.room)))
```

Timing: early vs late
 
```{r, results='asis'}
# tab <- table(races$treatment, ifelse(races$nsub>0, "Submission", "No submission"))
# tab2 <- addmargins(tab, 2, FUN=list(Total=sum))
# print(kable(tab2), type='html')
```

Using a Chi-square test of independence, we find no significant differences in participation rates associated with the assigned treatments (p-value: `r format.pval(chisq.test(tab)$p.value, digits=3)`); see Table XX.

Further, we model participation rates as a logistic regression. We use a polynomial of third degree for the count of past competitions to account for non-linear effects of experience; and we use an indicator for whether the competitor had a win or not. Also, taking into account differences in ability, participation rates are not significantly different.

Estimation results
---------------------

Participation to the competition by treatment is shown in Figure \ref{fig:entry}. Participation here is measured by the proportion of registered participants per treatment who made any submission during the eight-day submission period. Recall that competitors may decide to enter into the competition and work on the problem without necessarily submitting. In a tournament, for example, competitors are awarded a prize based on their last submission and may decide to drop out without submitting anything. However, this scenario seems unlikely.  In fact, competitors often end up making multiple submissions because by doing so they obtain intermediate feedback via preliminary scoring (see Section XXX for details). In a race, competitors have even stronger incentives to make early submissions as any submission that hits the target first wins. 

```
Table xxx
```

We find that the propensity to make a submission is higher in the Tournament than in the Race and in the Tournament with reserve, but the difference is not statistically significant (a Fisher's exact test gives a p-value of xxxxx). As discussed in Section XXX, we may not have enough power to detect differences below 5 percentage points. However, we find the same not-significant result in a parametric regression analysis of treatment differences with controls for the demographics and past experience on the platform; see Table \ref{entry}. Adding individual covariates reduces variability of outcomes, potentially increasing the power of our test.  In particular, Table \ref{entry} reports the results from a logistic regression on the probability of making a submissions. Column 1 reports the results from a baseline model with only treatment dummies. Column 2 adds demographics controls, such as the age, education, and gender. Column 3 adds controls for the past experience on the platform. Across all these specifications, the impact of the treatment dummies (including room size) on entry is not statistically significant. 


Simulation results
-------------------------


 
 
Empirical analysis
==================

Estimation results
------------------

Participation to the competition by treatment is shown in Figure
\[fig:entry\]. Participation here is measured by the proportion of
registered participants per treatment who made any submission during the
eight-day submission period. Recall that competitors may decide to enter
into the competition and work on the problem without necessarily
submitting. In a tournament, for example, competitors are awarded a
prize based on their last submission and may decide to drop out without
submitting anything. However, this scenario seems unlikely. In fact,
competitors often end up making multiple submissions because by doing so
they obtain intermediate feedback via preliminary scoring (see Section
XXX for details). In a race, competitors have even stronger incentives
to make early submissions as any submission that hits the target first
wins.

    Table xxx

We find that the propensity to make a submission is higher in the
Tournament than in the Race and in the Tournament with reserve, but the
difference is not statistically significant (a Fisher’s exact test gives
a p-value of xxxx). As discussed in
Section XXX, we may not have enough power to detect differences below 5
percentage points. However, we find the same not-significant result in a
parametric regression analysis of treatment differences with controls
for the demographics and past experience on the platform; see Table
\[entry\]. Adding individual covariates reduces variability of outcomes,
potentially increasing the power of our test. In particular, Table
\[entry\] reports the results from a logistic regression on the
probability of making a submissions. Column 1 reports the results from a
baseline model with only treatment dummies. Column 2 adds demographics
controls, such as the age, education, and gender. Column 3 adds controls
for the past experience on the platform. Across all these
specifications, the impact of the treatment dummies (including room
size) on entry is not statistically significant.

Simulation results
------------------