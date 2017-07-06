#****************************************#
#****************************************#
#****************************************#
#****************************************#
# Contest model of races and tournaments #
#****************************************#
#
# Args:
#  n: Competitors.
#  cy: Cost function of quality.
#  ct: Cost function of time.
#  ylim, tlim: Range values of costs.
#  cy.inv, ct.inv: Inverse cost function.
#  p, d, r: Probability distribution of ability.
#  upper: upper limit of ability.
#  V: vector of prizes structures.   
#  deadline, target: model parameters.
#  plot.results: plot bidding curves.
#
# Returns: 
#   Nothing.  
#
# Example:
# cy <- function(x) x^2
# ct <- function(x) 2*exp(1-x)
# z.lnorm <- f(n=c(3, 5, 10, 15, 50), cy=cy, ct=ct)
# z.wbull <- f(n=c(3, 5, 10, 15, 50), cy=cy, ct=ct
#             , p=pweibull, d=dweibull, r=rweibull, shape=1.5)
# ymax <- range(c(z.lnorm$ability$y, z.wbull$ability$y))[2]
# plot(z.lnorm$ability, typ='l', ylim=c(0, ymax))
# lines(z.wbull$ability, typ='l', lty=2)
#****************************************#
#****************************************#

v <- c(0.9, 0.1) 
p=punif; d=dunif; r=runif; xlim=c(0, 1)

# Cost functions
cx <- function(x) {
	x <- ifelse(x==0, .Machine$double.xmin, x)
 	x^(-1)
}
ct <- function(x) {
	x <- ifelse(x==0, .Machine$double.xmin, x)
 	x^(-0.5)
}
ct.inv <- function(x) {
	x <- ifelse(x==0, .Machine$double.xmin, x)
 	x^(-2)
}
cy <- function(x) x^2
cy.inv <- function(x) {
	x <- ifelse(x==0, .Machine$double.xmin, x)
	x^0.5
}
curve(cx, ylim=c(0, 4)); curve(ct, add=TRUE, lty=2); curve(cy, add=TRUE, lty=3)


# Density of k-th order statistic of n iid X's
dord <- function(x, k, n, ...) {
	z <- lfactorial(n) - lfactorial(k-1) - lfactorial(n-k) +
	(k-1)*p(x, log.p=TRUE, ...) + 
	(n-k)*p(x, log.p=TRUE, lower.tail=FALSE, ...) + 
	d(x, log=TRUE, ...)
	return(exp(z))
}
# Distribution of k-th order statistic of n iid X's
pord <- function(x, k, n, ...) {
	z <- 0
	for (j in k:n) {
	  z <- z + lfactorial(n) - lfactorial(j) - lfactorial(n-k) +
	  (j) * p(x, log.p=TRUE, ...)
	  (n-j) * p(x, log.p=TRUE, lower.tail=FALSE, ...)
	}
	return(exp(z))
}


#****************************************#
#****************************************#
f <- function(n, v, cx, cy, ct, cx.inv, cy.inv, ct.inv,
			, p=punif, d=dunif, r=runif, xlim=c(0, 1)
			, deadline=1, target=0
			, ...) {
	stopifnot(n>=3)
	q <- length(v); stopifnot(q < 3)
	v <- sort(v, decreasing=TRUE); stopifnot(sum(v)==1)
	ylim <- c(target, Inf)
	tlim <- c(0, deadline)

	# Equilibrium payoff in race or tournament with n rivals
	u0 <- function(x, y, ti, v, rivals, ...) {
		payoff <- function(x, v, rivals, ...) {
			v[1] * pord(x, k=rivals, n=rivals, ...) + 
			(1-v[1]) * (1 - pord(x, k=rivals, n=rivals, ...)) * pord(x, k=rivals-1, n=rivals-1, ...) 
		}
		costs <- ca(x) * cy(y) * ct(ti)
		return(payoff(x, v, rivals, ...) - costs)
	}
	# Bidding function
	b <- function(x, v, rivals, type=c("race", "tournament"), ...) {
		if (type=="race") {
			stopifnot(target>0)
			c.bid=ct; c.bid.inv=ct.inv
			c.scale <- cy(target)
			b0 <- c.bid(deadline)
			convention <- deadline
		} else {
			c.bid=cy; c.bid.inv=cy.inv
			c.scale <- ct(deadline)
			b0 <- c.bid(target)	
			convention <- 0
		}		
		v.scale <- v/c.scale
		marginal.type <- function(x, v, rivals, ...) {
			u0(x, y=target, ti=deadline, v=v, rivals=rivals, ...)
		}
		low.type <- uniroot(marginal.type, interval=xlim, v=v, rivals=rivals, ...)$root
		A <- function(x, k, rivals, ...) dord(x, k, rivals, ...) * x
		B <- function(x, k, rivals, ...) {
			(-dord(x, k, rivals, ...) * pord(x, k-1, rivals-1, ...) +
			dord(x, k-1, rivals-1, ...) * (1-pord(x, k, rivals, ...))) * x
		}
		integral.A <- function(x, n, low.type, ...) {
			integrate(A, k=n, rivals=n, upper=x, lower=low.type, ...)$val
		}
		integral.B <- function(x, n, low.type, ...) {
			integrate(B, k=n, rivals=n, upper=x, lower=low.type, ...)$val
		}
		out <- b0 + v.scale[1] * integral.A(x, rivals, low.type, ...) 
				+ (1-v.scale[1]) * integral.B(x, rivals, low.type, ...)
		return(ifelse(x>low.type, c.bid.inv(out), convention))
	}	

	# Parameters
	target <- 0.1
	deadline <- 5
	
	# Bids (this is "performance")
	b.3 <- sapply(seq(0.1, 0.9, length=5), b, v=v, rivals=3, type="tournament")
	b.6 <- sapply(seq(0.1, 0.9, length=5), b, v=v, rivals=6, type="tournament")
	signif(cbind(b.3, b.6, diff=b.3-b.6), 2)

	# Bids with different prize structure
	b.split <- sapply(seq(0.1, 0.9, length=5), b, v=c(0.5, 0.5), rivals=3, type="tournament")
	b.takeall <- sapply(seq(0.1, 0.9, length=5), b, v=c(1, 0), rivals=3, type="tournament")
	signif(cbind(b.split, b.takeall, diff=b.split-b.takeall), 2)
	
	# Race (this is "time")
	b.3 <- sapply(seq(0.1, 0.9, length=10), b, v=v, rivals=3, type="race")
	b.6 <- sapply(seq(0.1, 0.9, length=10), b, v=v, rivals=6, type="race")
	signif(cbind(b.3, b.6, diff=b.3-b.6), 2)

	# Tournament
	tournament <- function(x, v, rivals, ...) {
		y <- sapply(x, b, v=v, rivals=rivals, type="tournament", ...)
		u <- u0(x, y=y, ti=deadline, v=v, rivals=rivals, ...)
		out <- list(ability=x
					, score=y
					, utility=ifelse(y>0, u, 0)
					, timing=ifelse(y>0,deadline,0)
					, type="Tournament"
					, params=list(v=v, n=rivals))
		class(out) <- "contest"
		return(out)
	}
	
	# Example
	nobs <- 50
	t3 <- tournament(seq(0.1, 0.9, length=nobs), v=c(1, 0), rivals=3)
	t6 <- tournament(seq(0.1, 0.9, length=nobs), v=c(1, 0), rivals=6)
#	signif(cbind(r3=t3$utility, r6=t6$utility, diff=t3$utility-t6$utility), 3)

	t.split <- tournament(seq(0.1, 0.9, length=nobs), v=c(0.5, 0.5), rivals=6)

	
	# Plot
	plot.contest <- function(x, ...) {
		info <- sprintf("%s\n(alpha=%0.2f,n=%i)", x$type, x$params$v[1], x$params$n)
		with(x, plot(ability, score, type="b", ...)); title(info)
		with(x, plot(ability, timing, type="b", ...)); title(info)
		with(x, plot(ability, utility, type="b", ...)); title(info)
	}

	par(mfrow=c(3, 3))
	plot.contest(t3, pch=16, cex=.5, xlim=c(0,1))
	plot.contest(t6, pch=16, cex=.5, xlim=c(0, 1))
	plot.contest(t.split, pch=16, cex=.5, xlim=c(0, 1))

	# Race
	race <- function(x, v, rivals, ...) {
		ti <- sapply(x, b, v=v, rivals=rivals, type="race", ...)
		u <- u0(x, y=target, ti=ti, v=v, rivals=rivals, ...)
		out <- list(ability=x
					, score=ifelse(ti<deadline, target, 0)
					, utility=ifelse(ti<deadline, u, 0)
					, timing=ti
					, type="Race"
					, params=list(v=v, n=rivals))
		class(out) <- "contest"
		return(out)
	}

	# Example
	r3 <- race(seq(0.1, 0.9, length=nobs), v=c(1, 0), rivals=3)
	r6 <- race(seq(0.1, 0.9, length=nobs), v=c(1, 0), rivals=6)
	r.split <- race(seq(0.1, 0.9, length=nobs), v=c(0.5, 0.5), rivals=6)
	
	par(mfrow=c(3, 3))
	plot.contest(r3, pch=16, cex=.5, xlim=c(0,1))
	plot.contest(r6, pch=16, cex=.5, xlim=c(0, 1))
	plot.contest(r.split, pch=16, cex=.5, xlim=c(0, 1))

}


