
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


cum2ratio <- function(x, lag = 1, smooth = FALSE) # smooth can be a lambda value
{
    if (smooth)
    {
        x <- exp(tsmoothTS(log(x), lambda = smooth))
    }
    increments <- c(rep(NA, lag), diff(x, lag = lag))
    tail(increments, -lag) / head(increments, -lag)
}

## plot for subsets:

getRatio <- function(data, state = "Delhi", district = "", lag = 1, smooth = FALSE)
{
    ## aggregate over state / district. TODO: Similar function where
    ## state total is broken up into those from specified districts,
    ## and the rest
    dsub <- if (missing(district)) subset(data, State == state)
            else if (missing(state)) subset(data, District == district)
            else subset(data, State == state & District == district)
    where <- if (missing(district)) state
             else if (missing(state)) district
             else paste(state, district, sep = " / ")
    ## Now get one number per date: use dplyr?
    confirmed <- with(dsub, tapply(Confirmed, Date, sum))
    deaths <- with(dsub, tapply(Deceased, Date, sum))
    data.frame(where = where,
               rcases = cum2ratio(confirmed, lag = lag, smooth = smooth),
               rdeaths = cum2ratio(deaths, lag = lag, smooth = smooth),
               total = tail(confirmed, 1),
               date = tail(sort(unique(dsub$Date)), -lag))
}

prepanelq <- function(x, y, ...) list(ylim = quantile(y, c(0, 0.99), na.rm = TRUE))






