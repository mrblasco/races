#
#	Prepare datasets for analyis
#
#
#

baseline <- 0.792867
target <- 0.817866
winner <- 0.843962

with(races, data.frame(rating
		, ratingsrm=ifelse(algo_rating>0,algo_rating,NA)
		, nreg, nsub, nregsrm=algo_nreg, nsubsrm=algo_nsub
		, year=2015-year
		, paidyr=paid/(100*(1+2015-year))
		, nwins=ifelse(nwins==0,NA,nwins)
		, ntop5=ifelse(ntop5==0,NA,ntop5)
		, ntop10=ifelse(ntop10==0,NA,ntop10)
		, male, timezone, postgrad=ifelse(educ=="Postgraduate (MA)" | educ=="Phd", 1,0)
		, below30=ifelse(age=="<20" | age=="20-25" | age=="26-30", 1, 0)
		, risk, hours, hours12=week1, hours34=week2, hours56=week3, hours78=week4
)) -> covars

# Entry data
prepare.entry <- function(covars) {
	races$n <- ave(races$submit, races$room_id, FUN=length)
	entry0 <- aggregate(submit ~ n + room_id + treatment + room_size, data=races, sum)
	controls <- aggregate(covars, by=with(races, list(room_id=room_id)), mean, na.rm=TRUE)
	merge(entry0, controls)
}
adjust.controls <- function(data) {
	data$nwins <- impute(data$nwins, 'zero') > 0
	data$ntop5 <- NULL
	data$ntop10 <- log(impute(data$ntop10, 'zero')+1)
	data
}

# Final scores data
prepare.final <- function(covars) {
	info <- races[, c('coder_id',"room_id","treatment","room_size")]
	dat <- merge(scores, info, by='coder_id')
	final0 <- aggregate(final ~ room_id + treatment + room_size, data=dat, max)
	controls <- aggregate(covars, by=with(races, list(room_id=room_id)), mean, na.rm=TRUE)
	merge(final0, controls)
}
adjust.final <- function(dat) {
	y <- adjust.controls(dat)
	y$final <- y$final/1e6	
	y$final.cens <- ifelse(y$final<baseline, baseline, y$final) / target
	y$final <- y$final/target
	return(y)
}

# Speed data
prepare.speed <- function (covars) {
	races$days <- difftime(races$firstsub, "2015-03-08 12:00:00 EDT", units='days')
	races$days <- as.numeric(races$days)
	speed0 <- aggregate(days ~ room_id + treatment + room_size, data=races, mean)
	controls <- aggregate(covars, by=with(races, list(room_id=room_id)), mean, na.rm=TRUE)
	merge(speed0, controls)
}


# Get all data
final <- adjust.final(prepare.final(covars))
entry <- adjust.controls(prepare.entry(covars))
speed <- adjust.controls(prepare.speed(covars))
