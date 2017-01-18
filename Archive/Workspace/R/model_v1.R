f <- function(n, cy, ct, cy.inv=NULL, ct.inv=NULL
              , xlim=c(0, Inf), ylim=c(0, Inf), tlim=ylim
              , p=plnorm, d=dlnorm, r=rlnorm
              , deadline=1, target=1, V=1, inf.tol=1e2
              , type=c("bids", "utility"), ...) {
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
  if (any(V < 1/2 | V > 1)) stop("V must be higher then 1/2 and less than 1.")
  type <- match.arg(type)

  inverse <- function (f, lower, upper) {
    if (upper==Inf) upper <- inf.tol
    function (y) uniroot((function (x) f(x) - y), lower=lower, upper=upper)$root
  }
  if(is.null(cy.inv)) cy.inv <- inverse(cy, lower=cy(ylim[1]), upper=cy(ylim[2]))
  if(is.null(ct.inv)) ct.inv <- inverse(ct, lower=ct(tlim[1]), upper=ct(tlim[2]))
       
  # Density of an order statistic.
  dord <- function(x, k, n, ...) {
    z <- lfactorial(n) - lfactorial(k-1) - lfactorial(n-k) +
      (k-1)*p(x, log.p=TRUE, ...) + 
      (n-k)*p(x, log.p=TRUE, lower.tail=FALSE, ...) + 
      d(x, log=TRUE, ...)
    return(exp(z))
  }

  # Distribution of an order statistic.  
  pord <- function(x, k, n, ...) {
    z <- 0
    for (j in k:n) {
      z <- z + lfactorial(n) - lfactorial(j) - lfactorial(n-k) +
      (j) * p(x, log.p=TRUE, ...)
      (n-j) * p(x, log.p=TRUE, lower.tail=FALSE, ...)
    }
    return(exp(z))
  }
  
  # Define bidding function
  b <- function(x, n, V, ...) {
    integrand <- function(x, k, n, ...) dord(x, k, n, ...) * x
    integrand2 <- function(x, k, n, ...) {
      (- dord(x, k, n, ...) * pord(x, k-1, n-1, ...) +
      dord(x, k-1, n-1, ...) * (1-pord(x, k, n, ...))) * x
    }
    integral <- function(x, n, ...) {
      integrate(integrand, k=n, n=n, upper=x, lower=xlim[1], ...)$val
    }
    integral2 <- function(x, n, ...) {
      integrate(integrand2, k=n, n=n, upper=x, lower=xlim[1], ...)$val
    }
    cy.inv(cy(ylim[1]) + (V*integral(x, n, ...) + (1-V)*integral2(x, n, ...)) / ct(deadline))
  }

  # Equilibrium expected utility
  u <- function(x, ystar, tstar, k, n, V, ...) {
      if (x==0) return(-Inf)
      V * pord(x, k, n, ...) + 
      (1-V) * (1-pord(x, k, n, ...)) * pord(x, k-1, n-1, ...) - 
      cy(ystar)*ct(tstar) / x
  }
  
  # Equilibrium score in a race
  y.race <- function(x, n, V, ...) {
    xbar <- uniroot(u, ystar=target, tstar=deadline, k=n, n=n, V=V, interval=c(0, 10), ...)$root
    ifelse(x < xbar, 0, target)
  }
  
  # Equilibrium score in a tournament
  y.tournament <- function(x, n, V, ...) {
    sapply(x, b, n=n, V=V, ...)
  }

  # Initialize matrix of data
  out.names <- c("Race", "Tournament")
  out <- vector("list", length(out.names))
  names(out) <- out.names
  nsim <- 1e3
  m <- array(NA, dim=c(nsim, length(n), length(V)), dimnames=list(1:nsim, n, V))
  m2 <- m

  # Compute bids and plot
  if (type=="bids") {
    par(mfrow=c(length(V), length(n)), mar=c(4,4,2,2))
    ybar <- max(target, max(sapply(n, y.tournament, x=xlim[2], V=max(V), ...)))
    for (j in 1:length(V)) {
      for (i in 1:length(n)) {
        curve(y.tournament(x, V=V[j], n=n[i], ...)
            , from=xlim[1], to=min(inf.tol, xlim[2]), n=nsim
            , ylim=c(0, ybar)
            , ylab='y', xlab='x'
            , main=sprintf("n=%s, v=%s", n[i], signif(V[j], 2))) -> z
        curve(y.race(x, V=V[j], n=n[i], ...), n=nsim, add=TRUE, lty=2) -> z2
        m[ , i, j] <- z$y
        m2[ , i, j] <- z2$y
      }
    }
  }
  if (type=="utility") {
    x <- r(nsim, ...)
    for (j in 1:length(V)) {
      for (i in 1:length(n)) {
        m[, i, j] <- y.tournament(x, V=V[j], n=n[i], ...)
        m2[, i, j] <- y.race(x, V=V[j], n=n[i], ...)
      }
    }
  }

out[["Tournament"]] <- m
out[["Race"]] <- m2
return(out)
}


cy <- function(x) x^2
ct <- function(x) 2*exp(1-x)
z.lnorm <- f(n=c(3, 5, 10, 15, 30, 50), V=c(1/2, 1), cy=cy, ct=ct, inf.tol=20, type="utility")
sem <- function(x)sd(x)/sqrt(length(x))

# Comput stats
y.mean.tour <- apply(z.lnorm[["Tournament"]][,,2], 2, mean)
y.se.tour <- apply(z.lnorm[["Tournament"]][,,2], 2, sem)
x <- as.numeric(names(y.mean.tour))
y.mean.race <- apply(z.lnorm[["Race"]][,,2], 2, mean)
y.mean.n <- apply(z.lnorm[["Race"]][,,2], 2, length)
y.se.race <- sqrt(y.mean.race * (1-y.mean.race)  / y.mean.n)

# Plot
plot(x, y.mean.tour, ylim=c(0, .5), pch=16, xlab="n", ylab="y")
segments(x0=x, y0=y.mean.tour + y.se.tour, y1=y.mean.tour - y.se.tour, lwd=2)
segments(x0=x, y0=y.mean.tour + 2*y.se.tour, y1=y.mean.tour - 2*y.se.tour)

points(x, y.mean.race, pch=17, col=2)
segments(x0=x, y0=y.mean.race + y.se.race, y1=y.mean.race - y.se.race, lwd=2, col=2)
segments(x0=x, y0=y.mean.race + 2*y.se.race, y1=y.mean.race - 2*y.se.race, col=2)
legend("top",c("Tournament","Race"), bty='n', col=1:2, pch=16:17)
