
#' Order statistics density and distribution functions
#'
#' Density and distribution function of the  `k`'s order statistic for `n` iid random variables drawn from a given distribution `p` with density `d`.
#'
#' @param x vector of values
#' @param k,n order statistic and number of iid random variables
#' @param p,d distribution and density
#' @param ... further arguments for distribution and density
#' @return Probability of the k-th order statistic from n iid random variables
#'
#' @keywords order statistics
#' @name ord
#' @export
#' @examples
#' curve(dord(x, 1, 10, pnorm, dnorm, mean=0, sd=1), from=-4, to=4)
#' curve(dord(x, 10, 10, pnorm, dnorm, mean=0, sd=1), add=TRUE, lty=2)
#' curve(dnorm(x, mean=0, sd=1), add=TRUE, lty=3)
#' title("Density order statistics from 10 normal r.v.")
#' legend("topright", c("Min (1st OS)", "Max (n-th OS)", "Normal density"), lty=1:3, bty="n")

dord <- function(x, k, n, p, d, ...) {
	z <- lfactorial(n) - lfactorial(k-1) - lfactorial(n-k) +
	(k-1)*p(x, log.p=TRUE, ...) + 
	(n-k)*p(x, log.p=TRUE, lower.tail=FALSE, ...) + 
	d(x, log=TRUE, ...)
	return(exp(z))
}

#' @rdname ord
#' @export
pord <- function(x, k, n, p, d, ...) {
	z <- 0
	for (j in k:n) {
	  z <- z + lfactorial(n) - lfactorial(j) - lfactorial(n-k) +
	  (j) * p(x, log.p=TRUE, ...)
	  (n-j) * p(x, log.p=TRUE, lower.tail=FALSE, ...)
	}
	return(exp(z))
}

# Example
x <- seq(0.01, 1, lengt=10)
n <- 4
cost=c(-1, 2, -1)
p=punif; d=dunif; xlim=c(0, 1)
deadline=1; target=0.1


#' Contest simulation
contest <- function(x, n, type
			, v=c(1, 0), cost=c(-1, 2, -1)
			, p=punif, d=dunif, xlim=c(0, 1)
			, deadline=1, target=0.1, ...) {
	# Checks
	stopifnot(any(x<xlim[1] | x>xlim[2])==FALSE)
	stopifnot(n>2)
	stopifnot(length(v)==2)
	stopifnot(sign(cost)==c(-1,1,-1))
	x.min <- .Machine$double.xmin
	x <- ifelse(x==0, x.min, x)
	ylim <- c(target, Inf)
	tlim <- c(0, deadline)
	rivals <- n-1
	type <- match.arg(type, c("race","tournament"))
	
	# Cost functions
	cx <- function(x) x^(cost[1])
	cy <- function(x) x^(cost[2])
	ct <- function(x) x^(cost[3])
	cx.inv <- function(x) x^(1/cost[1])
	cy.inv <- function(x) x^(1/cost[2])
	ct.inv <- function(x) x^(1/cost[3])
	
	# Prob. of winning
	p1 <- pord(x, k=rivals, n=rivals, p=p, d=d, ...)
	p2 <- (1 - pord(x, k=rivals, n=rivals, p=p, d=d, ...)) * pord(x, k=rivals-1, n=rivals-1, p=p, d=d, ...)
	
	# Equilibrium utility
	u0 <- function(x, y, ti, v, p1, p2) {
		u <- v %*% c(p1, p2) - cx(x) * cy(y) * ct(ti)
		return(u)
	}
	 
	# Bidding function
	b <- function(x, v, rivals, p, d, low.type, c.bid, c.bid.inv, b0, convention=0, ...) {
		# Define internal functions
		A <- function(x, k, rivals, p, d,  ...) dord(x, k, rivals, p, d, ...) * cx.inv(x)
		B <- function(x, k, rivals, p, d, ...) {
			(-dord(x, k, rivals, p, d, ...) * pord(x, k-1, rivals-1, p, d, ...) +
			dord(x, k-1, rivals-1, p, d, ...) * (1-pord(x, k, rivals, p, d, ...))) * cx.inv(x)
		}
		integral.A <- function(x, n, low.type, p, d, ...) {
			integrate(A, k=n, rivals=n, upper=x, lower=low.type, p=p, d=d, ...)$val
		}
		integral.B <- function(x, n, low.type, p, d, ...) {
			integrate(B, k=n, rivals=n, upper=x, lower=low.type, p=p, d=d,...)$val
		}
		# Compute
		v1 <- integral.A(x, rivals, low.type, p, d, ...) 
		v2 <- integral.B(x, rivals, low.type, p, d, ...)		
		out <- b0 + v %*% c(v1, v2)
		return(ifelse(x > low.type, c.bid.inv(out), convention))
	}
	
	# Marginal type
	marginal.type <- function(x, v, rivals,  p=p, d=d, ...) {
		u0(x, y=target, ti=deadline, v=v, rivals=rivals, p=p, d=d,...)
	}
	low.type <- uniroot(marginal.type, interval=xlim, v=v, rivals=rivals, p=p, d=d,...)$root	

	# Compute bids
	if (type=="tournament") {
		b0 <- cy(target)
		y <- sapply(x, b, v=v/ct(deadline), rivals=rivals, p=p, d=d, low.type=low.type
				, c.bid=cy, c.bid.inv=cy.inv, b0=b0, convention=0, ...)
		u <- u0(x, y=y, ti=deadline, v=v, rivals=rivals, p=p, d=d,...)
		out <- list(ability=x, score=y
					, utility=ifelse(x < low.type, 0, u)
					, timing=ifelse(x < low.type, 0, deadline))
	} else {
		stopifnot(target>0)
		v.scale <- v / cy(target)
		b0 <- ct(deadline)
		ti <- sapply(x, b, v=v.scale, rivals=rivals, p=p, d=d, low.type=low.type
				, c.bid=ct, c.bid.inv=ct.inv, b0=b0, convention=deadline, ...)
		u <- u0(x, y=target, ti=ti, v=v, rivals=rivals, p=p, d=d, ...)
		out <- list(ability=x
				, score=ifelse(x < low.type, 0, target)
				, utility=ifelse(x < low.type, 0, u)
				, timing=ti)
	}
	out$marginal.type <- low.type
	out$type <- type
	out$params <- list(v=v, n=n, cost=cost)	
	out$target <- target
	out$deadline <- deadline
	class(out) <- "contest"
	return(out)
}


#' Plot contest object
plot.contest <- function(x, ...) {
	info <- sprintf("%s\n(alpha=%0.2f,n=%i)", x$type, x$params$v[1], x$params$n)
	with(x, plot(ability, score, type="b", ...)); title(info)
	abline(h=x$target, lty=3, col='lightgray')
	with(x, plot(ability, timing, type="b", ...)); title(info)
	abline(h=x$deadline, lty=3, col='lightgray')
	with(x, plot(ability, utility, type="b", ...)); title(info)
}

x <- seq(0.1, 1, length=50)
par(mfrow=c(2,3))
plot.contest(t4 <- contest(x, n=14,"tournament"), pch=16, cex=.5)
plot.contest(contest(x,n=4,"race"), pch=16, cex=.5)


