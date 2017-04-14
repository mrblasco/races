

# Create panel data
id <- levels(races$handle)
dat <- expand.grid(days=1:4, id=id)

dat$hours <- NA
dat$hours[dat$days==1] <- hours1
dat$hours[dat$days==2] <- hours2
dat$hours[dat$days==3] <- hours3
dat$hours[dat$days==4] <- hours4


submission.start <- strptime("2015-03-08 12:00",'%Y-%m-%d %H:%M') 
submission.end <- strptime("2015-03-15 13:00",'%Y-%m-%d %H:%M')
difference <- difftime(races.sub$timestamp, submission.start, unit="hours")
days <- as.numeric(difference) %/% 48 + 1

races.sub$nsub <- 1
nsub.agg <- with(races.sub, aggregate(nsub ~ days + handle, FUN=length))
panel <- merge(dat, nsub.agg, by.x=c("days", "id"), by.y=c("days", "handle"), all=TRUE)
panel$nsub[is.na(panel$nsub)] <- 0


index <- match(panel$id, races$handle)
panel$treatment <- races$treatment[index]

summary(panel)

summary(fit <- glm(nsub>0 ~ 1, data=panel)) # prob. submitting 15%
summary(fit <- glm(nsub>0 ~ factor(days), data=panel)) # Goes from 15% to 20% last 48h.
summary(fit <- glm(nsub>0 ~ treatment + factor(days), data=panel)) # nothing
summary(fit <- glm(nsub>0 ~ treatment*days, data=panel)) # nothing

