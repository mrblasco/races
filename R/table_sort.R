########
table.sorting <- function(x,	num=10) {
	vars <- colnames(x)
	n <- stat <- numeric(length(vars))
	est <- matrix(nrow=length(vars), ncol=4)
	rownames(est) <- vars
	colnames(est) <- c("Estimate", "Std. Error", "t value", "Pr(>|t|)")
	est2 <- est3 <- est
	for (i in 1:length(vars)) {
		m <- paste(vars[i], "~ submit*treatment + room_size")
		fit <- lm(m, data=cbind(races, x))
		stat[i] <- summary(fit)$fstatistic[1]
		est[i, ] <- summary(fit)$coef["submitTRUE", ]
		est2[i, ] <- summary(fit)$coef["submitTRUE:treatmenttournament", ]
		est3[i, ] <- summary(fit)$coef["submitTRUE:treatmentreserve", ]
		n[i] <- nobs(fit)
	}
	tab_list <- list(submit=cbind(est, Obs=n),tournament=cbind(est2, Obs=n),reserve=cbind(est3, Obs=n))
	out <- lapply(tab_list, function(x) x[order(abs(x[, 3]), decreasing=TRUE), ])
	with(out, rbind(head(submit, n=num), head(tournament, n=num), head(reserve, n=num)))
}

tab <- table.sorting(covars)

tab <- data.frame(rownames(tab), tab)
xtab <- xtable(tab)
colnames(xtab) <- c("Dep. variable", "Estimate", "Std. Error", "t-value", "p-value", "Obs.")
digits(xtab) <- c(1, 2, rep(2, ncol(tab)-2), 0)
align(xtab) <- c("@{}l","@{}l", rep("r", ncol(tab)-1))
caption(xtab) <- "Sorting"
label(xtab) <- "sorting"
attributes(xtab)$notes <- "xxxx"
render.xtable(xtab, add=list(cmd=c("\\\\[-1.8ex]&\\multicolumn{5}{@{}l}{Coefficient: Submit}\\\\\n"
	, "\\\\[1.8ex]&\\multicolumn{5}{@{}l}{Coefficient: Submit X Tournament}\\\\\n"
	, "\\\\[1.8ex]&\\multicolumn{5}{@{}l}{Coefficient: Submit X Reserve}\\\\\n")
	, pos=c(0, 6, 12))
	, include.rownames=FALSE)