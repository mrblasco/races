#
#	Custom settings for boxplots
#
#
#

boxplot.custom <- function(formula, data, ylim, ...) {
	h <- pretty(seq(ylim[1], ylim[2], length=5))
	colors <- c("brown", gray(0.75), gray(0.95))
 	boxplot(formula, data, col=colors, boxwex=0.5, frame=F, yaxt='n', xaxt="n", ylim=ylim, ...)
	abline(h=h, lty=3, col='lightgray')
 	boxplot(formula, data, col=colors, boxwex=0.5, frame=F, yaxt='n', xaxt="n", add=TRUE, ...)
	axis(2, at=h, h, col='lightgray', col.ticks='lightgray', las=2)
	axis(1, at=1:3, levels(final$treatment))
}
