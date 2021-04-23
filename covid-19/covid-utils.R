
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

cum2increments <- function(x, lag = 1, smooth = FALSE) # smooth can be a lambda value
{
    if (smooth)
    {
        x <- exp(tsmoothTS(log(x), lambda = smooth))
    }
    diff(x, lag = lag)
}

cum2ratio <- function(x, lag = 1, smooth = FALSE) # smooth can be a lambda value
{
    increments <- c(rep(NA, lag), cum2increments(x, lag = lag, smooth = smooth))
    tail(increments, -lag) / head(increments, -lag)
}

## India-specific functions: assumes data in format provided by covid19india.org

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
               icases = cum2increments(confirmed, lag = lag, smooth = smooth),
               ideaths = cum2increments(deaths, lag = lag, smooth = smooth),
               rcases = cum2ratio(confirmed, lag = lag, smooth = smooth),
               rdeaths = cum2ratio(deaths, lag = lag, smooth = smooth),
               total = tail(confirmed, 1),
               date = tail(sort(unique(dsub$Date)), -lag))
}

prepanelq <- function(x, y, ...) list(ylim = quantile(y, c(0, 0.99), na.rm = TRUE))


## divide cases (only) into urban / rural based on top districts as on March 1

getRatioUR <- function(data, state = "West Bengal",
                       districts = "",
                       cutoff.date = "2021-03-01",
                       cutoff.pc = 50,
                       cutoff.count,
                       lag = 7, smooth = FALSE)
{
    dsub <- subset(data, State == state)
    dcutoff <- subset(dsub, Date == cutoff.date)
    if (any(duplicated(dcutoff$District)))
        stop("duplicate districts, check code")
    if (missing(districts))
    {
        ## identify 'urban' districts that have highest
        conf <- dcutoff$Confirmed
        o <- order(conf, decreasing = TRUE)
        if (missing(cutoff.count))
        {
            ## choose top districts that cumulatively exceed 'cutoff.pc' percent of cases
            cpc <- 100 * cumsum(conf[o]) / sum(conf)
            cutoff.count <- which(cpc > cutoff.pc)[1]
        }
        districts <- head(dcutoff$District[o], cutoff.count)
        message(paste(districts, collapse = " / "))
    }

    ## aggregate over state / district. TODO: Similar function where
    ## state total is broken up into those from specified districts,
    ## and the rest
    durban <- subset(dsub, District %in% districts)
    drural <- subset(dsub, !(District %in% districts))
    where <- state
    ## Now get one number per date: use dplyr?
    curban <- with(durban, tapply(Confirmed, Date, sum))
    crural <- with(drural, tapply(Confirmed, Date, sum))
    data.frame(where = where,
               rurban = cum2ratio(curban, lag = lag, smooth = smooth),
               rrural = cum2ratio(crural, lag = lag, smooth = smooth),
               turban = tail(curban, 1),
               trural = tail(crural, 1),
               date = tail(sort(unique(dsub$Date)), -lag))
}





