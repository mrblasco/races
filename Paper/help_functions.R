####################################################
#               Helper functions
#             "Races Vs tournaments"
#           email: ablasco@fas.harvard.edu
####################################################



####################################################
# Render xtable
####################################################
render.xtable <- function(x, caption=caption(x), label=label(x), add=NULL, notes=NULL, ...) {
	#..............................................................#
	if (attributes(x)$class[1]!='xtable') stop("Missing xtable object")
	if (is.null(caption)) stop("Missing table caption")
	if (is.null(label)) stop("Missing table label")
	#..............................................................#
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
		cat("\\begin{tablenotes}\\footnotesize\n")                  
		cat(sprintf("%s\n", notes))
		cat("\\end{tablenotes}\n")
	}
	cat("\\end{table}\n")   
}


### Temporary
render.table <- function(x, caption, label, add=NULL, align=NULL, digits=1, notes=NULL) {
  if (is.null(align)) {
    align <- c("@{}l", rep("c", ncol(x)))
  }
  table.head <- "\\\\[-1.8ex]\\hline \\hline \\\\[-1.8ex]\n"
  table.mid <- "\\hline \\\\[-1.86ex]\n"
  table.bottom <- table.head
  add.to.cmd <- c(table.head, table.mid, table.bottom)
  add.to.row <- list(pos = list(-1, 0, nrow(x))
                , command = add.to.cmd)
  if (!is.null(add)) {
    add.to.row$command  <- c(add.to.row$command, add$cmd)
    add.to.row$pos[[4]] <- add$pos
  }
  cat("\\begin{table}\n")         
  cat("\\centering\n")                  
  cat(sprintf("\\caption{%s}\n", caption))
  cat(sprintf("\\label{%s}\n", label))
  print(xtable(x, caption, label, align, digits)
      , add.to.row=add.to.row
      , hline.after=NULL
      , floating=FALSE
      , comment=FALSE)
  if (!is.null(notes)) {
    cat("\\begin{tablenotes}\n")                  
    cat(sprintf("%s\n", notes))
    cat("\\end{tablenotes}\n")
  }
  cat("\\end{table}\n")   
}          


####################################################
# Render Factors with xtable
# chrishanretty.co.uk/blog/index.php/2009/07/02/summarizing-a-data-frame-with-xtable/
####################################################
xtable.factors <- function(foo, foo.test, ...) {
  bar <- matrix(nrow=length(unlist(foo)), ncol=4) # Initialize
  bar[, 1] <- gsub("\\..*","", names(unlist(foo))) ## 1st col has var name
  duplicated(bar[, 1]) -> duplicate.row 
  bar[, 1][duplicate.row] <- ""   ## don't repeat variable names
  bar[, 2] <- gsub(".*?\\.","", names(unlist(foo))) ## 2nd column has factor levels
  bar[, 3] <- as.numeric(unlist(foo))
  bar[, 3][is.na(bar[, 3])] <- 0 ## in case anything has been coerced
  bar[!duplicate.row, 4] <- format(foo.test, nsmall=3)
  colnames(bar) <- c("Variable","Response Category","Frequency", "P-value")
  rownames(bar) <- rep("", nrow(bar))
  return(xtable(bar, ...))
}

