stat_sum_single <- function(fun, geom="point", ...) {
  stat_summary(fun.y=fun, colour="red", geom=geom, size = 1, ...)
}

pathname <- "/Users/jake/Documents/workspace/crowd_words/output/costAnalysisByDoc/"

costNum <- 539

costData <- read.table(paste(pathname,toString(costNum),".tsv",sep=""), header=T)
costNum <- costNum + 539


while(costNum <= 539*15){
  costData <- rbind(costData,read.table(paste(pathname,toString(costNum),".tsv",sep=""),header=T))
  costNum <- costNum + 539
}

costData <- costData[costData$MinAcceptance < .7,]

costData$expAverageF <- exp(costData$AverageF)
costData <- costData[costData$pid != 10364520,]
costData <- costData[costData$pid != 8198128,]
costData <- costData[costData$pid != 7759075,]
costData <- costData[costData$pid != 3464560,]

minT <- 6
mina <- 0.4
maxr <- 0.1
maxC <- 5390

specParam <- costData[costData$MinAcceptance==mina,]
specParam <- specParam[specParam$MaxRejection == maxr,]
specParam <- specParam[specParam$MinTurkers==minT,]

specCost <- specParam[specParam$MaxCost==maxC,]
specCost <- specCost[with(specCost,order(AverageCost)),]
specCost$num <- 1:length(specCost[[1]])

g <- ggplot(specCost,aes(x=num))+geom_point(aes(y=AverageCost)) + geom_line(aes(y=AverageCost)) + geom_point(aes(y=AverageF*15,colour='red'),position="jitter")


#molten <- melt(specCost,id=c("AverageCost","MaxCost","MinAcceptance","MaxRejection","MinTurkers"))

f <- ggplot(specCost,aes(x=AverageCost,y=AverageF)) + geom_point()+stat_sum_single(mean,geom="line")+ggtitle(mean(specCost$AverageF)/mean(specCost$AverageCost))
filename <- paste('MinA',mina*10,'maxR',maxr*10,'minT',minT,'maxC',maxC,'.png',sep="")
ggsave(paste(pathname,"plots/",filename,sep=""),plot=g)
ggsave(paste(pathname,"plots/","Average",filename,sep=""),plot=f)
# f <- ggplot(costData,aes(x=AverageCost,y=AverageF,group=factor(MinTurkers),colour=factor(MinTurkers))) + geom_point()
# 
# molten <- melt(costData,id=c("MaxCost"))
# 
# avgF <- cast(molten,MaxCost~variable,mean)
# 
# h <- ggplot(costData,aes(x=MaxCost,y=AverageCost,group=factor(MinTurkers),colour=factor(MinTurkers))) + geom_point()#position="jitter")
# molten <- melt(costData,id=c("MinTurkers","MaxCost"))
# avgTurks <- cast(molten,MinTurkers~MaxCost~variable,mean)
# 
# a <- ggplot(costData,aes(x=MaxCost,y=AverageCost,group=factor(MaxRejection),colour=factor(MaxRejection))) + geom_point(position="jitter")
# 
# 
# specCost <- costData[costData$MaxCost == 5390,]
# 
# g <- ggplot(specCost,aes(x=AverageCost,y=AverageF,group=factor(MinAcceptance),colour=factor(MinAcceptance))) + geom_point(position="jitter")
