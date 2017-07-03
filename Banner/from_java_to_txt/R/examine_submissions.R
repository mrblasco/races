std <- function(x) sd(x)/sqrt(length(x))
y <- read.csv("~/Documents/NTL/Banner/BannerAlgorithm/tmp/txt/Breusov.csv")
y <- read.csv("~/Documents/NTL/Banner/BannerAlgorithm/tmp/txt/JRSSKumarD.csv")
y <- read.csv("~/Documents/NTL/Banner/BannerAlgorithm/tmp/txt/kubapb.csv")
y <- read.csv("~/Documents/NTL/Banner/BannerAlgorithm/tmp/txt/logico14.csv")
y <- read.csv("~/Documents/NTL/Banner/BannerAlgorithm/tmp/txt/megaterik.csv")
y <- read.csv("~/Documents/NTL/Banner/BannerAlgorithm/tmp/txt/orlovan.csv")#
y <- read.csv("~/Documents/NTL/Banner/BannerAlgorithm/tmp/txt/fugusuki.csv")#
#y <- read.csv("~/Documents/NTL/Banner/BannerAlgorithm/tmp/txt/EgorLakomkin.csv")#
#y <- read.csv("~/Documents/NTL/Banner/BannerAlgorithm/tmp/txt/Puffring.csv")#

y <- subset(y, subset_id>0)

cols <- seq(5, ncol(y),by=2)
precision <- matrix(NA,nrow(y),length(cols))
j <- 1
for (i in cols) {
    precision[, j] <- ifelse(y[,i]+y[,i+1]==0,jitter(0),y[,i] / (1+y[, i] + y[,i+1]))
    j <- j + 1
}

# By abstract
std <- function(x) sd(x)/sqrt(length(x))
prec.mean <- apply(precision,1,mean)
prec.std <- apply(precision,1,std)

# Figure
par(mfrow=c(2,2),family="serif")
hist(prec.mean,breaks="Scott",xlab="mean precision",main=NA)
plot(prec.mean, y$anno,pch="+",xlab="mean precision",ylab="annotations")
hist(prec.std,breaks="Scott",xlab="st.err. precision",main=NA)
plot(prec.std, y$anno,pch="+",xlab="st.err. precision",main=NA,ylab="annotations")


# By submission
prec.mean <- apply(precision,2,mean)
prec.std <- apply(precision,2,std)

# Figure
plot(prec.mean,type="b", col=2,ylim=c(.65,.8))
lines(prec.mean + 1.96*prec.std, col=2)
lines(prec.mean - 1.96*prec.std, col=2)
abline(h=prec.mean[1],lty=2)