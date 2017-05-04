# Zero profit condition implies
# R(a)  = C(a, k)

# R(x) is concave function. 
# alpha: fraction prize pool to the winner
# n: competitors
# F: distribution of abilities
R <- function(x, alpha, n, F, ...) {
    if (alpha < 0.5)
        stop("Less than 1/2 alpha specified.")
    if (alpha > 1)
        stop("Greater than one alpha specified.")
    if (n < 2)
        stop("Less than 2 competitors specified.")
    if (F(x, ...) < 0 || F(x, ...) > 1)
        stop("Negative probability specified.")

    alpha * F(x, ...)^(n) + (1-alpha) * (1-F(x, ...)^(n)) * F(x, ...)^(n-1) 
}

# Derivative of revenues
R.deriv <- function(x, alpha, n, F, f, ...) {
	check <- R(x, alpha, n, F, ...)
	alpha * n * F(x, ...)^(n-1) * f(x, ...) + 
	(1-alpha) * (1-F(x, ...)^(n)) * (n-1) * F(x, ...)^(n-2) * f(x, ...) - 
	(1-alpha) * n * F(x, ...)^(n-1) * f(x, ...) * F(x, ...)^(n-1)
}

# G function (inverse)
xR.inverse <- function(x, alpha, n, F, ...) {
	uniroot(function(y) y*R(y, alpha, n, F, ...) - x, lower=0, upper=1)$root
}
xR.inverse(0.15, 1,10,pbeta, shape1=2,shape2=5)
xR.inverse(0.25, 1,10,pbeta, shape1=2,shape2=5)
xR.inverse(0.5, 1,10,pbeta, shape1=2,shape2=5)
xR.inverse(0.75, 1,10,pbeta, shape1=2,shape2=5)
xR.inverse(0.9, 1,10,pbeta, shape1=2,shape2=5)
xR.inverse(1, 1,10,pbeta, shape1=2,shape2=5)

curve(xR.inverse(x, 1,10,pbeta, shape1=2,shape2=5), from=0.5, to=0.75)


# Revenues with uniform-distributed abilities
par(mfrow=c(1, 2))
competitors <- 5
curve(R(x, alpha=1.0, n=competitors, F=punif)
	, ylab="Revenues", xlab="Ability", main="Uniform distribution")
curve(R(x, alpha=0.75, n=competitors, F=punif), add=TRUE, lty=2)
curve(R(x, alpha=0.5, n=competitors, F=punif), add=TRUE, lty=3)

# Revenues with beta-distributed abilities
curve(R(x, alpha=1, n=competitors, F=pbeta, shape1=2, shape2=5)
	, ylab="Revenues", xlab="Ability", main="Beta(2, 5) distribution")
curve(R(x, alpha=0.75, n=competitors, F=pbeta, shape1=2, shape2=5), add=TRUE, lty=2)
curve(R(x, alpha=0.5, n=competitors, F=pbeta, shape1=2, shape2=5), add=TRUE, lty=3)
########################################


