# Breusov
y <- read.csv("~/Documents/NTL/Banner/BannerAlgorithm/tmp/txt/fugusuki.csv")
#y <- read.csv("~/Documents/NTL/Banner/BannerAlgorithm/tmp/txt/Breusov.csv")
y$subset_id <- ifelse(y$subset_id>0,1,0)

# First submission
precision <- y[,5] / (1+y[,5] + y[,6])
sensitivity <- y[,5] / y[,4]
last <- ncol(y)-1
precision2 <- y[, last] / (1+y[,last] + y[,ncol(y)])
sensitivity2 <- y[,last] / y[,4]

# Figure 1
par(mfrow=c(1,2))#non-evaluation subset
boxplot(cbind(sensitivity, sensitivity2)[y$subset_id==0, ],ylab="Sensitivity",ylim=c(0,1),notch=T,col=2)
boxplot(cbind(precision, precision2)[y$subset_id==0, ],ylab="Precision",ylim=c(0,1),notch=T,col=3)

par(mfrow=c(1,2))#evaluation subset
boxplot(cbind(sensitivity, sensitivity2)[y$subset_id==1, ],ylab="Sensitivity",ylim=c(0,1),notch=T,col=2)
boxplot(cbind(precision, precision2)[y$subset_id==1, ],ylab="Precision",ylim=c(0,1),notch=T,col=3)
