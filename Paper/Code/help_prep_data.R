
na.count <- function(x) sum(is.na(x))
replace.pattern <- function(x, p1, p2) gsub(x, pattern=p1, replacement=p2)

# Capitalize letters
capitalize <- function(x) {
  substr(x, 1, 1) <- toupper(substr(x, 1, 1))
  return(x)
}

# Standard handles
standardize.handle <- function(x) {
  x %>% as.character %>% trimws %>% tolower %>%
    replace.pattern("@gmail.com", "") %>%
    replace.pattern("vidhyabhushan.*", "vidhyabhushanv") %>%
    as.factor -> x
  return(x)
}

# Unique id
unique.by.id <- function(x, id) {
  index <- tapply(1:nrow(x), id, head, n=1)
  return(x[index, ])
}

# Imputations
impute.zero <- function(x) ifelse(is.na(x), 0, x)

impute.at.random <- function(x, ...) {
  x.missing <- is.na(x)
  x[x.missing] <- sample(levels(x), replace=TRUE, size=sum(x.missing), ...)
  return(list(imputed=x, missing.yes=x.missing))
}
 