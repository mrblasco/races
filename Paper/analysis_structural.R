## Structural estimation
# Assumptions:
# 	1) Alpha = 1 
# 	2) gamma(x)C = exp(a -x * b)

## Equations:
# (1) Pr(entry) = Pr(x >= threshold) = 1 - F(threshold)
# (2) Zero profit ==> F(threshold)^(n-1) = gamma(threshold) C
# Assumptions + (1) + (2) ==>
# (3) 1 - exp(a - x * b)^(1/(n-1))

# Response function
response.fun <- function(p, x, n) {
  	zero <- .Machine$double.eps
	one <- 1 - zero
	if (length(p)!=2) stop("Parameter vector `p` must be of length 2")
	if (n < 2) stop("Competitors `n` must be greater than or equal to 2")
	eta <- (p[1] + x * p[2]) * (1 / (n - 1))
	prb <- 1 - exp(-eta)
	prb[prb < 0] <- zero
	prb[prb > 1] <- one
	prb
}

# Log likelihood
loglik <- function(p, x, y, n) {
  fv <- response.fun(p, x, n) 
  -sum(dbinom(y, 1, fv, log=TRUE))
}

# Example
ncomp <- 6
n <- 300
p  <- c(4, -0.5)
x <- rbinom(n, 1, 0.5) #rnorm(n)
y <- rbinom(length(x), 1, response.fun(p, x, ncomp))
sol <- nlm(loglik, p=c(-10, 0.1), x=x, y=y, n=ncomp)
sol

# Test consistency / biased
replicate(1e3, {
	y <- rbinom(length(x), 1, response.fun(p, x, ncomp))
 	p.start <- 1- exp( - coef(glm(y ~ x)) * (1 / (ncomp - 1)))
	sol <- nlm(loglik, p=p.start, x=x, y=y, n=ncomp)
	sol$estimate
}) -> est

boxplot(t(est))
points(1:2, p, col=2, pch=16)


# Prepare data
ncomp <- ifelse(races$room_size=='Large', 15, 10)
x <- ifelse(races$treatment=='tournament', 1, 0)
y <- ifelse(races$submit==1, 1, 0)


p.start <- 1- exp( - coef(glm(y ~ x)) * mean((1 / (ncomp - 1))))
sol <- nlm(loglik, p=p.start, x=x, y=y, n=ncomp)
sol

# bootstrap
obs <- length(y)
replicate(999, {
	index <- sample(obs, replace=TRUE)
	x.boot <- x[index]
	y.boot <- y[index]
	ncomp.boot <- ncomp[index]
	mu <- mean((1 / (ncomp.boot - 1)))
	p.start <- 1- exp( - coef(glm(y.boot ~ x.boot)) * mu)
	sol <- nlm(loglik, p=p.start, x=x.boot, y=y.boot, n=ncomp.boot)	
	sol$estimate
}) -> est

boxplot(t(est))
abline(h=0, col=2)











