#************************************************************************#
# HELPER FUNCTIONS		 												 #
#************************************************************************#

# Inverse logistic
ilogit <- function(x) return(exp(x) / (1+ exp(x)))

# Capitalize initials
capitalize <- function(x) {
	initials <- substring(x, 1, 1)
  	paste(toupper(initials), substring(x, 2), sep="")
}

compile.report <- function() {
	system('sh compile.sh report.Rmd Paper')
}

#------------------------------------------------------------------------#
# Function rendering xtable objects in a nice latex format
#
# Input: xtable object
# Output: well formatted latex table
#------------------------------------------------------------------------#
render.xtable2 <- function(x, add=NULL, ...) {
	#..............................................................#
	require(xtable)
	if (attributes(x)$class[1]!='xtable') stop("Missing xtable object")
	if (is.null(caption(x))) stop("Missing table caption")
	if (is.null(label(x))) stop("Missing table label")
	#..............................................................#
	caption <- caption(x)
	label <- label(x)
	notes <- attributes(x)$notes
	top <- "\\\\[-1.8ex]\\hline\\hline\\\\[-1.8ex]\n"
	middle <- "\\hline\\\\[-1.86ex]\n"
	bottom <- "\\hline\\\\[-1.8ex]\n"
  	cmd <- c(top, middle, bottom)
  	pos <- list(-1, 0, nrow(x))
  	add.to.row <- list(pos=pos, command=cmd)
  	if (!is.null(add)) {
    	add.to.row$command  <- c(add.to.row$command, add$cmd)
    	add.to.row$pos[[4]] <- add$pos
  	}
	cat("\\begin{table}\n\\centering\n")
	cat(sprintf("\\caption{%s}\n", caption))
	cat(sprintf("\\label{%s}\n", label))
	print(x, add.to.row=add.to.row
	  , hline.after=NULL
	  , floating=FALSE
	  , comment=FALSE
	  , ...)
	if (!is.null(notes)) {
		cat("\\begin{minipage}{\\textwidth}\n")                  
		cat(sprintf("\\footnotesize\\emph{Notes:}{%s\n}", notes))
		cat("\\end{minipage}\n")
	}
	cat("\\end{table}\n")   
}




#------------------------------------------------------------------------#
# Function rendering xtable objects with factors in a nice latex format
#
# Input: xtable object with factors
# Output: well formatted latex table
# Notes: 
# 	"summarizing-a-data-frame-with-xtable" from chrishanretty.co.uk/blog/
#------------------------------------------------------------------------#
xtable.factors <- function(x, pval, ...) {
	require(xtable)
	elements <- unlist(x)
	elements.percent <- unlist(sapply(x, function(x) round(100*x/sum(x))))
	elements.names <- names(elements)
	tab <- matrix(nrow=length(elements), ncol=5) # Initialize
	tab[, 1] <- gsub("\\..*","", elements.names) ## 1st col has var name
	duplicated(tab[, 1]) -> duplicate.row 
	tab[, 1][duplicate.row] <- ""   ## don't repeat variable names
	tab[, 2] <- gsub(".*?\\.","", elements.names) ## 2nd column has factor levels
	tab[, 3] <- as.numeric(elements)
	tab[, 3][is.na(tab[, 3])] <- 0 ## in case anything has been coerced
	tab[, 4] <-  paste(as.numeric(elements.percent),"%", sep='')
	tab[!duplicate.row, 5] <- format(pval, nsmall=3)
	colnames(tab) <- c("Variable","Response Category","Frequency", "Percent","P-value")
	rownames(tab) <- rep("", nrow(tab))
	return(xtable(tab, ...))
}

