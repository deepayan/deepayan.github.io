
## Utility functions shared across reports

## crude correction for possible lag in recording counts (see France, for example) 

correctLag <- function(x)
{
    n <- length(x)
    stopifnot(n > 2)
    for (i in seq(2, n-1))
        if (x[i] == x[i-1])
            x[i] <- sqrt(x[i-1] * x[i+1])
    x
}


## doubling time

## doubling time given a vector of counts
tdouble <- function(n, x, min = 50)
{
    if (x[n] < min) return (NA_real_)
    x <- head(x, n)
    x <- c(0, x[x > 0])
    i <- seq_along(x)
    f <- approxfun(x, i)
    diff(f(max(x) * c(0.5, 1)))
}

## cumulative doubling time with available data as function of time
doubling.ts <- function(region, d, min = 50, start = as.Date("2020-01-22"))
{
    t <- seq(start, by = 1, length.out = nrow(d))
    td <- sapply(1:nrow(d), tdouble,
                 x = d[, region, drop = TRUE], min = min)
    data.frame(region = region, date = t, tdouble = td)
}


