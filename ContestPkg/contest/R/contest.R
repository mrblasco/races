
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
pord <- function(x, k, n, p, ...) {
	z <- 0
	for (j in k:n) {
	  z <- z + lfactorial(n) - lfactorial(j) - lfactorial(n-k) +
	  (j) * p(x, log.p=TRUE, ...)
	  (n-j) * p(x, log.p=TRUE, lower.tail=FALSE, ...)
	}
	return(exp(z))
}

#' Tournament and race contest games
#'
#' Computes equilibrium bids and expected utility of a contest game with `n` rivals competing for two prizes of value `prizes` for a vector of iid abilities `x` drawn from a given distribution `p` with density `d`.
#'
#' @param x vector of ability values
#' @param n number of competitors
#' @param type a contest game can be either a `race` or a `tournament`
#' @param prize value of 1st and 2nd prize (must sum to one)
#' @param elasticity vector of length 3 with elasticities for the cost function with respect ability, performance, and time. 
#' @param p,d ability distribution and density
#' @param xlim vector of lowest and highest possible abilities
#' @param deadline,target time deadline and minimum performance target
#' @param ... further arguments for distribution and density
#' @return A `contest` object
#'
#' @keywords contest, races, tournaments, game theory
#' @name contest
#' @export
#' @examples
#' contest(seq(0.1,0.9,length=10), n=10, type="race")

contest <- function(x, n, type=c("race","tournament"), prize=c(1, 0), elasticity=c(-1, 2, -1)
								, p=punif, d=dunif, xlim=c(0, 1), deadline=1, target=0.1, ...) {
	stopifnot(all(x <= xlim[2] & x >= xlim[1])) # Check ability interval
	stopifnot(n>2) # Check number of competitors
	rivals <- n-1
	type <- match.arg(type)
	stopifnot(length(prize)==2 & sum(prize)==1 & diff(prize)<=0) # Check prize
	stopifnot(sign(elasticity)==c(-1, 1, -1))	
	ALPHA <- elasticity[1]
	BETA <- elasticity[2]
	GAMMA <- elasticity[3]
	cost <- function(x, elasticity) {
		if (elasticity<1) x <- ifelse(x==0, .Machine$double.xmin, x)
		return(x^(elasticity))
	}
	tlim <- c(0, deadline)
	ylim <- c(target, cost(sum(prize)/(cost(xlim[2], ALPHA) * cost(deadline, GAMMA)), 1/BETA))
	stopifnot(diff(ylim)>0 & diff(tlim)>0)
	payoff <- function(x, y, z, prize, rivals, p, ...) {
			p1 <- pord(x, rivals, rivals, p, ...)
			p2 <- (1 - p1) * pord(x, rivals-1, rivals-1, p, ...)
			cost0 <- cost(x, ALPHA) * cost(y, BETA) * cost(z, GAMMA)
			prize[1] * p1 + prize[2] * p2 - cost0
	}
	A <- function(x, n, p, d,...) dord(x, n, n, p, d, ...) / cost(x, ALPHA)
	B <- function(x, n, p, d, ...) {
		(-dord(x, n, n, p, d, ...) * pord(x, n-1, n-1, p, ...) +
		dord(x, n-1, n-1, p, d, ...) * (1-pord(x, n, n, p, ...))) / cost(x, ALPHA)
	}
	type.zero <- uniroot(payoff, interval=xlim, y=target, z=deadline, prize=prize, rivals=rivals, p=p)$root
	v1 <- sapply(x, function(k) integrate(A, upper=k, lower=type.zero, n=rivals, p=p, d=d)$val)
	v2 <- sapply(x, function(k) integrate(B, upper=k, lower=type.zero, n=rivals, p=p, d=d)$val)
	if (type=='tournament') { 
		b0 <- cost(target, BETA)
		prize.scaled <- prize / cost(deadline, GAMMA)
		ystar <- cost(b0 + prize.scaled[1] * v1 + prize.scaled[2] * v2, 1/BETA) # Missing scaling
		ustar <- ifelse(x<type.zero, 0, payoff(x, ystar, deadline, prize, rivals, p))
		tstar <- ifelse(x<type.zero, 0, deadline)
	} else {
		b0 <- cost(deadline, GAMMA)
		prize.scaled <- prize / cost(target, BETA)
		tstar <- cost(b0 + prize.scaled[1] * v1 + prize.scaled[2] * v2, 1/GAMMA)
		tstar <- ifelse(x<type.zero, deadline, tstar)
		ustar <- ifelse(x<type.zero, 0, payoff(x, target, tstar, prize, rivals, p))
		ystar <- ifelse(x<type.zero, 0, target)	
	}
	out <- list(ability=x, score=ystar, timing=tstar, utility=ustar)
	out$marginal.type <- type.zero
	out$type <- type
	out$params <- list(prize=prize, n=n, elasticity=elasticity, target=target, deadline=deadline)	
	class(out) <- "contest"
	return(out)
}

#' Plot contest object
#'
#' Plot equilibrium bids and expected utility of a contest game with `n` rivals competing for two prizes of value `prizes` for a vector of iid abilities `x` drawn from a given distribution `p` with density `d`.
#'
#' @param x contest object
#' @param ... further arguments for distribution and density
#' @return Probability of the k-th order statistic from n iid random variables
#'
#' @keywords order statistics
#' @export
#' @examples
#' plot(example(contest))

plot.contest <- function(x, ...) {
	info <- sprintf("%s\n(alpha=%0.2f,n=%i)", x$type, x$params$v[1], x$params$n)
	with(x, plot(ability, score, type="b", ...)); title(info)
	abline(h=x$param$target, lty=3, col='lightgray')
	with(x, plot(ability, timing, type="b", ...)); title(info)
	abline(h=x$param$deadline, lty=3, col='lightgray')
	with(x, plot(ability, utility, type="b", ...)); title(info)
}