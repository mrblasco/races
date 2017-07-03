rm(list=ls())
setwd("~/NTL/NTL_banner")

## Functions
upload <- function(filename){
   empty <- file.info(filename)$size==0
   if (!empty) {
      x <- read.csv(filename, header=FALSE)
      names(x) <- c("abstract","position","label")
      return(x) 
   } else {
      return(NULL)
   }
}
extract_data <- function(y, groundtruth) {
   if (!is.null(y)) {
      z <- split(groundtruth, groundtruth$abstract)
      ## Extract all annotations
      vec <- lapply(z, function(gtf) {
            k <- gtf$abstract[1] ## Abstract id
            index <- y$abstract==k
            tp <- rep(0,nrow(gtf)) ## true positives
            n <- sum(index) ## label per abstract k
            if (n>0) {
               for (j in 1:n) {
                  h <- which(index)[j] ## index for j
                  posit <- ifelse(y[h,2]==gtf[,2],1,0) ## positions
                  label <- ifelse(y[h,3]==gtf[,3],1,0) ## labels   
                  tp <- tp + posit*label
               }
            }
            ## Return values
            return(list(tot_labels=length(tp)
                  ,positions=tp
                  ,true_positives=sum(tp)
                  ,total_positives=n
               )
            )
         })
   } else {
      vec <- list(tot_labels=NA
               ,positions=NA
               ,true_positives=NA
               ,total_positives=NA
            )
   }
   return(vec)
}
transform_df <- function(vec) {
   x <- sapply(vec, function(x)sapply(x,paste,collapse=""))
   out <- data.frame(abstract=names(vec), t(x))
   return(out)
}
write.data <- function(x, ...) {
  write.table(x,row.names=FALSE,sep=",",quote=FALSE,...)
}

################################################
## Ground Truth Data
gtffile <- "Data/MM/Submissions/EvaluateSolutions/gtf.csv"
gtf <- upload(gtffile)

## All Submissions
allfiles <- list.files("Data/MM/Submissions/Solutions",pattern=".*txt",full.names=T)

## Upload all files
cat("Uploading all files...\n")
system.time(dat <- try(lapply(allfiles,upload)))
names(dat) <- gsub(".*/(.*).txt","\\1",allfiles)
cat("...done!\n")

## Extract
cat("Extracting data...\n")
system.time(out <- lapply(dat,extract_data,groundtruth=gtf))
cat("...done!\n")


## Print the data out 
cat("Printing...")
yy <- lapply(out, transform_df)
out <- "banner_disagg_scores.csv"
for(i in 1:length(yy)) { 
   if (i==1){
      write.data(list(submission=names(yy)[i], yy[[i]]),file=out)
      } else {
      write.data(list(names(yy)[i], yy[[i]]),file=out,append=T,col.names=FALSE)
   }   
}
cat("...done!\n")
cat("Finished.\n")
