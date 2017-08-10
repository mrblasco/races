################################################################
#
#	Compute descriptive statistics
#
#
# Example:
# descriptives(races[, c('rating','nsub','nreg')])
################################################################
descriptives.test <- function(data) {
	d <- data.frame(treatment=races$treatment, data)
	models <- lapply(paste(names(data), "treatment", sep = "~"), formula)
	sapply(models, function(x) summary(lm(formula=x, data=d))$fstat[1])
} 
descriptives <- function(data) {
	mu <-sapply(data, mean, na.rm=TRUE)
	q50 <-sapply(data, median, na.rm=TRUE)
	lo <-sapply(data, min, na.rm=TRUE)
	hi <-sapply(data, max, na.rm=TRUE)
	std <-sapply(data, sd, na.rm=TRUE)
	n <- sapply(data, function(x) sum(!is.na(x)))
	fstat <- descriptives.test(data)
	tab <- cbind(mu, q50, std, lo, hi, n, fstat)
	colnames(tab) <- c("Mean", "Median","St.Dev.", "Min", "Max", "Obs.", "F-statistic")
	return(tab)
}
