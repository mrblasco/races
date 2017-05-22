
# Scores
z <- merge(scores, races, by='coder_id')
attach(z)

final_pc <- exp(final/1e8)
final_l <- split(final, treatment)
kruskal.test(final_l) # Significant differences in final score distriubution

# Plot
index <- is.na(final)
plot(density(final[!index]))
sapply(final_l, function(x) {
	index <- is.na(x)
	lines(density(x[!index]))
})


# Plot score distribution by rooms
boxplot(final ~ paste(treatment, room), horizontal=TRUE, outline=FALSE, las=2, varwidth=TRUE)