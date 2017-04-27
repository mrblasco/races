rm(list=ls())
options(digits=3)
require(stargazer)
ilogit <- function(x) exp(x)/(1+exp(x)) 

# Create panel data
load("Data/survey.RData")


