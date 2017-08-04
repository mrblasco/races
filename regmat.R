# 
#	Matrix with regression coefficients and standard errors 
# 
#
#
regmat <- function(x, digits=3, dep.var.labels=NULL, omit="^$", ...) {
	create.matrix <- function(object) {
		results <- coef(summary(object))
		est <- round(results[,1], digits)
		SE <- paste("(", round(results[,2], digits), ")", sep='')
		lab <- rownames(results)
		n <- length(est)
		values <- as.vector(rbind(est, SE))
		vlabels <- as.vector(rbind(lab, rep('', n)))
		vnames <- rep(lab, each=2)
		vstat <- rep(colnames(results)[1:2], n)
		data.frame(vnames, vstat, vlabels, values)
	}
	merge.all <- function(m1, m2) {
		merge(m1, m2, by=c('vnames', 'vstat', 'vlabels'), all=TRUE)
	}
	m_list <- lapply(x, create.matrix)
	if (is.null(dep.var.labels)) {
		get.depvar <- function(object) as.character(formula(object))[2]
		dep.var.labels <- sapply(x, get.depvar)
	}
	output <- Reduce(merge.all, m_list)
	rows <- 1:nrow(output)
	if (!is.null(omit)) rows <- setdiff(rows, grep(omit, output$vnames))
	output <- output[rows, -c(1:2)]
	colnames(output) <- c("Coefficient names", dep.var.labels)
	output
}
# 
# 
# # Example
# models <- paste(colnames(covars), "submit*treatment", sep='~')
# models.fit <- sapply(models, function(x) lm(formula=x, data=cbind(covars, races)))
# m <- regmat(models.fit, omit='Interce|^treat')
# xtable(t(m))