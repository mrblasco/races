load("races.RData")

panel.smooth <- function (x, y, col="dodgerblue", bg=NA, pch=18, 
                        cex=0.8, col.smooth="red", span=2/3, iter=3, ...) {
  points(x, y, pch = pch, col = col, bg = bg, cex = cex)
  ok <- is.finite(x) & is.finite(y)
  if (any(ok)) 
    lines(stats::lowess(x[ok], y[ok], f = span, iter = iter), 
          col = col.smooth, ...)
}
panel.hist <- function(x, ...) {
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(usr[1:2], 0, 1.5) )
  h <- hist(x, breaks="Scott", plot = FALSE)
  breaks <- h$breaks; nB <- length(breaks)
  y <- h$counts; y <- y/max(y)
  rect(breaks[-nB], 0, breaks[-1], y, col="gray", ...)
}
panel.cor <- function(x, y, digits=2, cex.cor)
{
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  r <- abs(cor(x, y, use='complete.obs'))
  txt <- format(c(r, 0.123456789), digits=digits)[1]
  test <- cor.test(x,y)
  Signif <- ifelse(round(test$p.value,3)<0.001,"p<0.001",paste("p=",round(test$p.value,3)))  
  text(0.5, 0.25, paste("r=",txt))
  text(.5, .75, Signif)
}

z <- data.frame(score=dat$lastscore, experience=dat$mm.count, submissions=dat$nsub)
plot(z, lower.panel=panel.cor, upper.panel=panel.smooth, diag.panel=panel.hist)

x <- cbind(dat$mm.count, !is.na(dat$nsub))
id <- cut(dat$mm.count, breaks=c(-1, 0, 1, 2, 4, 10, 80, Inf), include.lowest=TRUE)
entry <- ifelse(!is.na(dat$nsub), 1, 0)
plot(aggregate(entry, by=list(id), mean))
