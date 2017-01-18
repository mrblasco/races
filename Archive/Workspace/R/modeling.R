```{r}

# Simulations for the appendix

p <- pweibull
zeroprofit <- function(a, n, s0, c0) {
  p(a, s0)^n - c0 * exp(-a) 
}
# Compute marginal
marginal <- function(num, shape, cost, ...) {
  uniroot(f=zeroprofit, n=num, s0=shape, c0=cost, interval=c(0.0001, 10), ...)$root
}

# Plot 
par(mfrow=c(3,3))
for (nn in c(3, 4, 5, 8, 10, 15, 20, 30, 50)) {
  curve(zeroprofit(x, n=nn, s0=1, c0=0.75), from=0.0001, to=3
      , main=sprintf("n=%i",nn), ylab="R(a)", xlab="a")
  abline(h=0, lty=2, col=2)
  for (ss in seq(0.5, 5, length=10))
    curve(zeroprofit(x, n=nn, s0=ss, c0=0.75), add=TRUE, col=gray(ss/5))
}
loglik <- function(par, y) {
  marginaltype <- marginal(num=4, shape=par[1], cost=par[2])
  ll <- y * p(marginaltype, shape=par[3], log.p=TRUE) + 
        (1 - y) * p(marginaltype, shape=par[3], log.p=TRUE, lower.tail=FALSE)
  mean(ll)
}

    p=pweibull 
    loglik <- function(par, y) {
      n <- length(y)
      ones <- sum(y)
      zeros <- n - ones
      ll <- ones * p(par[1], shape=par[2], log.p=TRUE) + 
            zeros * p(par[1], shape=par[2], log.p=TRUE, lower.tail=FALSE)
      mean(ll)
    }
    # Simulate
    n <- 300
    threshold <- 1
    shape <- 1.5
    y <- ifelse(rweibull(n, shape=shape)>threshold, 1, 0)
    # MLE
    optim(par=runif(2), fn=loglik, y=y, method="L-BFGS-B"
          , lower=c(0.1, 0.1), upper=c(2, 5), control=list(fnscale=-1))

# Simulate
obs <- 300
par0 <- c(n=4, s0=1.5, c0=0.75)
marginal0 <- marginal(num=par0[1], shape=par0[2], cost=par0[3])
y <- ifelse(rweibull(obs, shape=par0[2]) >= marginal0, 1, 0)

# Method of moments binmial
pbar <- mean(y)



# Maximize
# optim(par=c(0.5, 1, 1), f=loglik, y=y, method="L-BFGS-B", lower=c(0.01, 0.5, 0.5), upper=c(0.99, 5, 5), control=list(trace=109, fnscale=-1, pgtol=0.0001)) -> out
optim(par=runif(2), f=loglik, y=y, method="L-BFGS-B", lower=c(0.01, 0.01), upper=c(5, 5), control=list(trace=109, fnscale=-1, pgtol=0.0001)) -> out
out
optim(par=runif(2), f=loglik, y=y, control=list(trace=109, fnscale=-1))

# Random
m <- matrix(ncol=4, nrow=1e3)
for (i in 1:nrow(m)) { 
  x <- c(runif(1), 1.5, 1.5)
  m[i, ] <- c(x, loglik(x, y=y))
}
m[which.min(m[, 4]), ]

curve(zeroprofit(x,  c0, shape=shape), from=0.0001, to=10)
curve(zeroprofit(x,  out$par[1], shape=out$par[2]), lty=2, add=TRUE, col=2)
abline(h=0, lty=6)

# z[is.na(z)] <- -1
# op <- par(bg = "white")
# persp(s.30, c.30, z, theta = 130, phi = 30, expand = 0.5, col = "lightblue", ticktype='detailed') -> res
# lines (trans3d(x=s.30, y=c0, z = max(z), pmat = res), col = 2)

```
