
## Community
x <- read.table("~/NTL/Banner/Data/MM/page_views_temp.tsv",sep="\t",header=T)
table(x$ga.eventAction,x$ga.eventCategory)

file <- "~/Dropbox (Harvard-NTL)/Banner/Data/MM/pageviews/query_explorer-8.tsv"
x <- read.table(file,skip=14,nrows=958, sep="\t",header=T)
table(x$ga.eventAction,x$ga.eventCategory)

## Other 16 in WWW
x <- read.table("~/NTL/Banner/Data/MM/pageviews/page_views_help.tsv",sep="\t",header=T)
table(x$ga.eventAction,x$ga.eventCategory)

## Help.Topcoder (2328)
## Master (2328)

16372?


## Other 16 in WWW
x <- read.table("~/NTL/Banner/Data/MM/pageviews/page_views_master.tsv",sep="\t",header=T)
table(x$ga.eventAction,x$ga.eventCategory)


x <- read.table("~/NTL/Banner/Data/MM/pageviews/allproblem.tsv",sep="\t",header=T)
sort(table(x$ga.eventAction))


https://www.googleapis.com/analytics/v3/data/ga?ids=ga%3A42830633&start-date=300daysAgo&end-date=yesterday&metrics=ga%3Apageviews&dimensions=ga%3AeventCategory%2Cga%3AeventLabel%2Cga%3AeventAction%2Cga%3Adate&filters=ga%3AeventCategory%3D~Problem&max-results=9999999


