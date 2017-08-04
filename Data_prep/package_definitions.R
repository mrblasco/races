#' Dataset for races vs tournaments study
#'
#' Sample: demographics, skill rating, individual outcomes, and assignment to treatment groups
#'
#' @docType data
#' @usage data(races)
#'
#' @keywords contests, races, tournaments
#'
#' @examples
#' data(races)
#' summary(races)

"races"

#' Dataset for races vs tournaments study
#'
#' Submissions panel data
#'
#' @docType data
#' @usage data(scores)
#'
#' @keywords contests, races, tournaments
#'
#' @examples
#' data(scores)
#' summary(scores)

"scores"

#' Dataset for races vs tournaments study
#'
#' Final survey data
#'
#' @docType data
#' @usage data(final_survey)
#'
#' @keywords contests, races, tournaments
#'
#' @examples
#' data(final_survey)
#' summary(final_survey)

"final_survey"

#' Inverse logit
#'
#' Inverse logit function
#' @keywords inverse logit
#' @export
#' @examples
#' curve(ilogit, from=-5, to=-5)

ilogit <- function(x) exp(x)/(1+exp(x)) 

#' Impute missing values
#'
#' Impute missing values at random or with a zero.
#' @keywords imputing, missing values
#' @export
#' @examples
#' impute(c(1, 2, 3, NA), "random")

impute <- function(x, type=c("random", "zero")) {
	type <- match.arg(type)
	miss <- is.na(x)
	if (type=='random') {
		x[miss] <- sample(x[!miss], size=sum(miss), replace=TRUE)
	} else {
		x[miss] <- 0
	}
	return(x)
}

#' Capitalize
#'
#' Capitalize initial letter of words in a string.
#' @keywords capitalize
#' @export
#' @examples
#' capitalize("word1 word2")

capitalize <- function(x) {
	initials <- substring(x, 1, 1)
  	paste(toupper(initials), substring(x, 2), sep="")
}


#' Render xtable
#'
#' Render xtable objects in nice latex format
#' @keywords xtable
#' @export
#' @examples
#' xtab <- xtable(table(sample(1:5, size=20, replace=TRUE)))
#' render.xtable(xtab)

render.xtable <- function(x, add=NULL, ...) {
	if (class(x)[1]!='xtable') 
		stop("Missing xtable object")
	if (is.null(caption(x))) 
		stop("Missing table caption")
	if (is.null(label(x))) 
		stop("Missing table label")
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
				add.to.row$command <- c(add.to.row$command, add$cmd)
				add.to.row$pos <- c(add.to.row$pos, add$pos)
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
