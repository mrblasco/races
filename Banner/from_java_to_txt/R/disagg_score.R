rm(list=ls())
# FILES
ground_truth_file       <- "~/Documents/NTL/Banner/BannerAlgorithm/tmp/gtf.csv"
data_link_file              <- "~/Documents/NTL/Banner/BannerAlgorithm/tmp/data_link.csv"
submission_folder       <- "~/Documents/NTL/Banner/BannerAlgorithm/tmp/submissions"
output_folder               <- "~/Documents/NTL/Banner/BannerAlgorithm/tmp/txt"

# List of user folders
users0 <- read.csv("~/Documents/NTL/Banner/BannerAlgorithm/tmp/users.csv")
users <- as.character(users0[users0$done==0,1])

# Data link file
make_base_data <- function()
{
    gtf0 <- read.table(ground_truth_file,sep=",")#(abstract,position,value)
    x0 <- data.frame(table(gtf0[,1]))
    x <- merge(dlf,x0,by.x="V1",by.y="Var1")
    names(x) <- c("id","subset_id","abstract_id","annotations")
    return(x)
}
dlf <- read.table(data_link_file,sep=",")#(abstract,position,value)
gtf <- readLines(ground_truth_file)
dat <- make_base_data()

compute_score <- function(sf)
{
    sf_paper_id <- as.numeric(gsub("(^[0-9]+),.*","\\1",sf))
    stopifnot(any(!unique(sf_paper_id) %in% dlf[,1])==FALSE)
    # If row of gtf is not found, then we have fn "false negative"
    # If row of gtf is found, then we have tp "true positive"
    # If row of submission is not found on gtf, then we have fp "false positive"
    tp <- sf %in% gtf #true positives
    fp <- !sf %in% gtf #false positives
    out <- aggregate(list(tp=tp, fp=fp), by=list(id=sf_paper_id), sum)
    return(out)
}
## 
setwd(submission_folder)
for (i in 1:length(users))
{
    print(users[i])
    sf_list <- list.files(users[i])
    num <- as.numeric(gsub(".*-([0-9]+).txt","\\1",sf_list))
    sf_list <- sf_list[order(num)]#sorted
    num <- num[order(num)]#sorted
    z <- dat
    for (j in 1:length(sf_list))
    {
        sf <- readLines(paste(users[i], sf_list[j],sep="/"))
        if (length(sf)>0){
            z0 <- compute_score(sf)
            names(z0)[2:3] <- paste(names(z0)[2:3],num[j],sep="_")
            z <- merge(z, z0,all.x=T,by="id")
        }
    }
    z[is.na(z)] <- 0
    outfile <- paste(output_folder,"/",users[i],".csv",sep="")
    write.table(file=outfile,z,sep=",",quote=FALSE,row.names=FALSE)
}
