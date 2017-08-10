#
#
#	This scripts customize stargazer output
#
#
# Example:
# tab.panel <- list(panel1=lm(runif(100) ~ 1), panel2=lm(runif(100) ~ 1))
# regtab(tab.panel, panels=TRUE)

regtab <- function(x, panels=FALSE, caption=NULL, label=NULL, notes=NULL, notes.width=1, ...) {
  cat('\\begin{table}\n\\centering\n')  
  cat(sprintf('\\caption{%s}', caption))
  cat(sprintf('\\label{%s}', label))
#   if (panels) sapply(x, regtab.inner, ...)
#   else regtab.inner(x, ...)
	regtab.inner(x, ...)
  if (!is.null(notes)) {
    cat(sprintf('\\begin{minipage}{%f\\textwidth}\n', notes.width))
    cat(sprintf('\\footnotesize\\emph{Note:} %s\n', notes))
    cat('\\end{minipage}\n')
  }
  cat('\\end{table}\n')  
}
regtab.inner <- function(x, ...) {
	if(class(x)=='list') n <- length(x) else n <- 1
	align.string <- paste(c("{@{}l", rep("c", n), "}"), collapse='')
  tab <- capture.output(stargazer(x, header=FALSE, float=FALSE, ...))
	tab <- gsub("\\\\begin\\{tabular.*", paste("\\\\begin{tabular}", align.string, sep=''), tab)
  index <- grep("Note:", tab)
  cat(tab[-index], sep='\n')
} 
