costNum <- 539

pathname <- "/Users/jake/Documents/workspace/crowd_words/output/costAnalysis/"

costDat <- read.table(paste(pathname,toString(costNum),".tsv",sep=""), header=T)
costNum <- costNum + 539


while(costNum <= 539*15){
  costDat <- rbind(costDat,read.table(paste(pathname,toString(costNum),".tsv",sep=""),header=T))
  costNum <- costNum + 539
}

specData <- costDat[costDat$MinTurkers==3,]
specData <- specData[specData$MinAcceptance==.6,]
specData <- specData[specData$MaxRejection==.4,]


#costData <- costData[costData$MinAcceptance < .7,]

costData$expAverageF <- exp(costData$AverageF)

f <- ggplot(costData,aes(x=AverageCost,y=AverageF,group=factor(MinTurkers),colour=factor(MinTurkers))) + geom_point()

molten <- melt(costData,id=c("MaxCost"))

avgF <- cast(molten,MaxCost~variable,mean)

h <- ggplot(costData,aes(x=MaxCost,y=AverageCost,group=factor(MinTurkers),colour=factor(MinTurkers))) + geom_point()#position="jitter")
molten <- melt(costData,id=c("MinTurkers","MaxCost"))
avgTurks <- cast(molten,MinTurkers~MaxCost~variable,mean)

a <- ggplot(costData,aes(x=MaxCost,y=AverageCost,group=factor(MaxRejection),colour=factor(MaxRejection))) + geom_point(position="jitter")


specCost <- costData[costData$MaxCost == 5390,]

g <- ggplot(specCost,aes(x=AverageCost,y=AverageF,group=factor(MinAcceptance),colour=factor(MinAcceptance))) + geom_point(position="jitter")
