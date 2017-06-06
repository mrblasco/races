#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# Simulate contest model described in the paper #
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

#****************************************#
# EXAMPLE	a ~ Uniform(0,1)
#****************************************#

## Checks
# v in (0, 1)
# a in (0, 1)
# alpha <= -1

integral_1 <- function(v, a, n, alpha, a0) {
	u <- n-1-alpha
	v * (a^u -  a0^u) / u
}
integral_2 <- function(v, a, n, alpha, a0) {
	u <- (n-2-alpha)
	r <- ((n-2)*(u+1) - a*(n-1) * u ) / (u*(u+1))
	r0 <- ((n-2)*(u+1) - a*(n-1) * u) / (u*(u+1))
	(1-v) * (a^u * r - a0^u * r0)
}
y.tournament <- function(v, a, n, alpha, beta) {
	V <- integral_1(v, a, n, alpha, a0=0) + integral_2(v, a, n, alpha, a0=0) 
	V^(1/beta)
}
payoff <- function(ya, ta, v, a, n, alpha, beta, gamma) {
 v * a^(n-1)  +
 (1-v) * (1-a) * a^(n-2) - 
 a^alpha * ya^beta * ta^gamma
}

y <- function(v=0.75, n=4, alpha=-1, beta=2, gamma=-1, t0=1, ...){ 
 	out <- curve(y.tournament(v, a=x, n, alpha, beta), ann=FALSE, ...) 
	util <- payoff(ya=out$y, ta=t0, v, a=out$x, n, alpha, beta, gamma)
	return(list(a=out$x, ystar=out$y, ustar=util))
}

abilityhat <- uniroot(payoff, interval=c(0,1), v=0.5, n=4, alpha=-1, beta=2)$root

curve(y(v=0.5, a=x, n=4, alpha=-1, beta=2), n=1001, ann=FALSE, lty=2)
segments(x0=abilityhat, y0=0, y1=y0, lty=3)
segments(x0=abilityhat, x1=1, y0=y0, y1=y0)
title("Equilibrium bids in a race")
mtext("a ~ Uniform(0,1)", 1,3)
mtext("y(a)", 2,3)


par(mfrow=c(1, 2))

# FIGURE
y(v=1, lty=1, from=0, to=1) -> x.1
y(v=0.75, add=TRUE, lty=2)	-> x.75
y(v=0.5, add=TRUE, lty=3)	-> x.50
title("Equilibrium in a tournament")
mtext("a ~ Uniform(0,1)", 1,3)
mtext("y(a)", 2,3)

plot(x.1$a, x.1$ustar, type='l', lty=1, ann=FALSE)
lines(x.75$a, x.75$ustar, lty=2)
lines(x.50$a, x.50$ustar, lty=3)
title("Equilibrium payoffs in a tournament")
mtext("a ~ Uniform(0,1)", 1,3)
mtext("pi(a)", 2,3)



## Util functions

# Inverse of a function
inverse <- function (f, lower, upper) {
	if (is.infinite(upper)) upper <- .Machine$integer.max
	function (y) uniroot((function (x) f(x) - y), lower=lower, upper=upper)$root
}


#-------------------------------------------------#
# Bidding function for races and tournaments.
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
#-------------------------------------------------#
f <- function(n, cy, ct, cy.inv=NULL, ct.inv=NULL
              , xlim=c(0, Inf), ylim=c(0, Inf), tlim=ylim
              , p=plnorm, d=dlnorm, r=rlnorm
              , deadline=NULL, target=NULL, V=1
              , type=c("bids", "utility")
              , ...) {
	# Checks
	if (any(V<1/2 | V>1)) stop("V must be higher then 1/2 and less than 1.")
	type <- match.arg(type)

	# Default values	
	if (is.null(deadline)) deadline <- tlim[2]
	if (is.null(target)) target <- ylim[2]
	if (is.null(cy.inv)) cy.inv <- inverse(cy, lower=cy(ylim[1]), upper=cy(ylim[2]))
	if (is.null(ct.inv)) ct.inv <- inverse(ct, lower=ct(tlim[1]), upper=ct(tlim[2]))

	# Probability density function of the kth order statistic of n abilities
	dord <- function(x, k, n, ...) {
	z <- lfactorial(n) - lfactorial(k-1) - lfactorial(n-k) +
	  (k-1)*p(x, log.p=TRUE, ...) + 
	  (n-k)*p(x, log.p=TRUE, lower.tail=FALSE, ...) + 
	  d(x, log=TRUE, ...)
	return(exp(z))
	}

	# Cumulative distribution function of the kth order statistic of the n abilities
	pord <- function(x, k, n, ...) {
	z <- 0
	for (j in k:n) {
	  z <- z + lfactorial(n) - lfactorial(j) - lfactorial(n-k) +
	  (j) * p(x, log.p=TRUE, ...)
	  (n-j) * p(x, log.p=TRUE, lower.tail=FALSE, ...)
	}
	return(exp(z))
	}

	########################################
	## Equilibrium expected utility
	## Args:
	#	y.stars, t.star mean 'optimal'
	#	x: ability
	#	n: number of participants
	#	V: prize
	#	requires cy, ct, pord
	u <- function(x, y.star, t.star, V, n, ...) {
		x <- ifelse(x==0,.Machine$double.xmin, x)
		k <- n # n-th highest of n variables
		costs <- cy(y.star) * ct(t.star) / x
		revenues <- V * pord(x, k, n, ...) + 
		(1-V) * (1-pord(x, k, n, ...)) * pord(x, k-1, n-1, ...) 
		return(revenues - costs)
	}

	## Tournament
	# Equilibrium bid function (quality)
	b <- function(x, n, V, ...) {
		A <- function(x, k, n, ...) dord(x, k, n, ...) * x
		B <- function(x, k, n, ...) {
			( -dord(x, k, n, ...) * pord(x, k-1, n-1, ...) +
			dord(x, k-1, n-1, ...) * (1-pord(x, k, n, ...))) * x
		}
		integral.A <- function(x, n, ...) {
			integrate(A, k=n, n=n, upper=x, lower=xlim[1], ...)$val
		}
		integral.B <- function(x, n, ...) {
			integrate(B, k=n, n=n, upper=x, lower=xlim[1], ...)$val
		}
		v <- V/ct(deadline) # Prizes scaled by time
		b <- cy(ylim[1]) + v*integral.A(x, n, ...) + (1-v)*integral.B(x, n, ...)
		return(cy.inv(b))
	}

	# Wrapper
	y.tournament <- function(x, n, V, ...) {
		sapply(x, b, n=n, V=V, ...)
	}
	
  
	## Race
	# Equilibrium bid function (quality)
	y.race <- function(x, n, V, ...) {
		xbar <- uniroot(u, y.star=target, t.star=deadline, n=n, V=V, interval=xlim, ...)$root
		ifelse(x < xbar, 0, target)
	}
  

  
 ## Plot
#   if (type=="bids") {
#     par(mfrow=c(length(V), length(n)), mar=c(4,4,2,2))
#     ybar <- max(target, max(sapply(n, y.tournament, x=xlim[2], V=max(V), ...)))
#     for (j in 1:length(V)) {
#       for (i in 1:length(n)) {
#         curve(y.tournament(x, V=V[j], n=n[i], ...), from=xlim[1], to=min(inf.tol, xlim[2])
#             , ylim=c(0, ybar), ylab='y', xlab='x'
#             , main=sprintf("n=%s, alpha=%s", n[i], signif(V[j], 2)))
#         curve(y.race(x, V=V[j], n=n[i], ...), add=TRUE, lty=2)
#       }
#     }
#   }
}



# Example
cy <- function(x) x^2
ct <- function(x) exp(1-x)
ct.inv <- function(u) 100 - u
cy.inv <- function(u) u^0.5

ylim <- c(0, 1)
xlim <- c(0, 1)
tlim <- c(0, 1) 
deadline <- tlim[2]
target <- ylim[1]
V <- 0.5
n <- 3
# p=plnorm; d=dlnorm; r=rlnorm
p=punif; d=dunif; r=runif

par(mfrow=c(1, 2))
bids <- curve(y.tournament(x, n=n, V=V), from=xlim[1], to=xlim[2])
payoffs <- curve(u(x, y.tournament(x, n=n, V=V), deadline, V=V, n=n), from=xlim[1], to=xlim[2])

x <- 0
u(x, y.tournament(x, n=n, V=V), deadline, V=V, n=n)


# Example:
cy <- function(x) x^2
ct <- function(x) 2*exp(1-x)
z.lnorm <- f(n=c(3, 10, 15, 50), cy=cy, ct=ct)
z.wbull <- f(n=c(3, 10, 15, 50), cy=cy, ct=ct
            , p=pweibull, d=dweibull, r=rweibull, shape=1.5)



