## ignore flambda but could be gamma in gam()

smoothConfirmed <- function(x, flambda = 1)
{
    require(mgcv)
    ## x is cumulative confirmed cases
    xx <- pmax(diff(x), 0)
    t <- seq_along(xx)
    fm <- gam(xx ~ 1 + s(t), family = poisson, gamma = flambda)
    cumsum(c(x[1], predict(fm, type = "response")))
}

smoothActive <- function(x, flambda = 1)
{
    require(mgcv)
    ## x is active cases, no need to diff. family = posson?
    t <- seq_along(x)
    fm <- gam(x ~ 1 + s(t), family = poisson, gamma = flambda)
    c(predict(fm, type = "response"))
}




## estimate growth rate parameter using three different
## methods. 'data' should have columns (a) 'confirmed' and (b) 'active',
## or 'recovered' + 'deceased'.
## lag: value of time difference used to estimate
## smooth: currently unsupported

## Return value: three new columns added giving date-wise rate
## estimates

estimate.growth <-
    function(data, lag = 7, smooth = FALSE, mu = 1/10,
             confirmed = "confirmed",
             active = "active",
             recovered = "recovered",
             deceased = "deceased")
{
    if (is.null(data[[active]]))
        data[[active]] <-
            data[[confirmed]] - data[[recovered]] - data[[deceased]]
    x <- data[[confirmed]]
    a <- data[[active]]
    if (smooth) {
        ## smooth using mgcv
        x <- smoothConfirmed(x, flambda = as.numeric(smooth))
        a <- smoothActive(a, flambda = as.numeric(smooth))
    }
    dx <- diff(x, lag = lag) # loses lag days
    da <- diff(a, lag = lag) # loses lag days
    ## method 3
    rho <- tail(dx, -lag) / head(dx, -lag) # loses lag more days
    ## method 1
    lambda1 <- dx / (lag * head(a, -lag))
    ## method 2
    lambda2 <- da / (lag * head(a, -lag)) + mu
    data[["rho"]] <- c(rep(NA_real_, lag), rho, rep(NA_real_, lag))
    data[["lambda1"]] <- c(lambda1, rep(NA_real_, lag))
    data[["lambda2"]] <- c(lambda2, rep(NA_real_, lag))
    attr(data, "lag") <- lag
    attr(data, "mu") <- mu
    class(data) <- c("growthrate", class(data))
    data
}


aggregate.data <- function(data, state = "Delhi", district = "")
{
    ## aggregate over state / district. 
    dsub <- if (missing(district)) subset(data, State == state)
            else if (missing(state)) subset(data, District == district)
            else subset(data, State == state & District == district)
    where <- if (missing(district)) state
             else if (missing(state)) district
             else paste(state, district, sep = " / ")
    ## Now get one number per date: use dplyr?
    confirmed <- with(dsub, tapply(Confirmed, Date, sum))
    deceased <- with(dsub, tapply(Deceased, Date, sum))
    recovered <- with(dsub, tapply(Recovered, Date, sum))
    data.frame(where = where,
               confirmed = confirmed,
               deceased = deceased,
               recovered = recovered,
               date = sort(unique(dsub$Date)))
}

predict.growthrate <-
    function(object, days = 100,
             from = NULL, # date of prediction. defaults to latest
             linear = FALSE, # whether rate remains constant (FALSE) or grows linearly (TRUE) 
             adjust = FALSE, # adjust jump in active counts to account for lag
             rate.smooth = 4, # estimate rate by taking average of estimates over last few days
             plag = attr(object, "lag"),
             ...)
{
    ## This version only uses the 'active' method (see prediction-utils-orignal.R) 
    ## assumes 'date' variable, but really only need row index
    lag <- attr(object, "lag")
    mu <- attr(object, "mu")
    from <- 
        if (!is.null(from)) as.Date(from)
        else tail(object$date, lag)[1]
    ## drop any data we have after from + lag
    object <- subset(object, date <= from)
    ## to predict using rho, we need data from past 2*lag+1 days as
    ## well. FIXME: can do with less for active method
    date <- from + seq(-2 * lag, days) # 0 = current (predict from 1 onward)
    d <- data.frame(date = date,
                    method = "active",
                    confirmed = NA_real_,
                    active = NA_real_)
    d$confirmed[seq_len(2*lag + 1)] <- tail(object$confirmed, 2*lag + 1)
    d$active[seq_len(2*lag + 1)] <- tail(object$active, 2*lag + 1)
    from.index <- which(object$date == from-1)
    if (length(from.index) != 1)
        stop("Invalid from.index: ", from.index)
    ## rate <- object$lambda2[from.index]
    past.rates <- object$lambda2[seq(from.index - rate.smooth, from.index)]
    rate <- mean(past.rates[-1])
    slope <-
        if (linear) coef(lm(past.rates ~ 1 + seq_along(past.rates)))[2] # mean(diff(past.rates))
        else 0
    ## slope <- max(slope, 0)
    if (is.na(rate)) {
        print(object)
        stop("rate not available for starting date")
    }
    message(sprintf("rate parameter: %g, slope parameter: %g, prediction lag: %g",
                    rate, slope, plag))
    if (plag > lag) stop("'plag' cannot exceed 'lag'")
    ## if (plag < lag) rate <- rate + (lag - plag) * slope # update rate linearly if necessart
    ## OR, even if using plag < lag, start with the same lambda
    d <-
        within(d,
        {
            for (i in (seq_len(days)))
            {
                k <- i + (2 * lag + 1)
                ## str(list(from = from, k = k, i = i, lag = lag, rate = rate,
                ##          confirmed[k-lag], confirmed[k-2*lag]))
                active[k] <-
                    max(active[k - plag] * (1 + plag * (rate - mu)), 0)
                ## crude approximation, not important
                confirmed[k] <- confirmed[k - 1] +
                    active[k] - active[k - 1] + mu * active[round(k - 0.5 * plag)]
                rate <<- rate + slope
                if (i == 1 && adjust && plag > 1)
                {
                    message("adjusting active and confirmed counts to ensure smoothness")
                    ## modify confirmed and active to
                    ## change linearly in last plag days to
                    ## reduce plag-day jumps in predictions
                    ii <- seq(k - plag + 1, k) # length = plag
                    active.lag <- active[k - plag + 1]
                    active[ii] <- active.lag +
                        (active[k] - active.lag) * (ii - ii[1]) / (plag - 1)
                    confirmed.lag <- confirmed[k - plag + 1]
                    confirmed[ii] <- confirmed.lag +
                        (confirmed[k] - confirmed.lag) * (ii - ii[1]) / (plag - 1)
                    rm(ii, active.lag, confirmed.lag)
                }
            }
            rm(i, k)
        })
    d
}

## For now: explore with method=active

predictZone <- function(data, ..., lag = 7, plag = lag, mu = 1/10, title = NULL,
                        smooth = FALSE,
                        drop.before = NULL,
                        linear = FALSE,
                        max.predict = 35, # don't predict more than these many days
                        predict.at = c("2021-03-03", "2021-03-17", "2021-03-31"))
{
    d <- aggregate.data(dall, ...)
    fm <- estimate.growth(d, lag = lag, mu = mu, smooth = smooth)
    q <-
        xyplot(lambda2 - 0.1 ~ date, data = fm, type = "l",
               subset = if (is.null(drop.before)) TRUE else date >= as.Date(drop.before),
               ylab = expression(lambda(t) - mu),
               abline = list(h = 0, col = "grey", lwd = 3),
               grid = TRUE)
    if (missing(title))
    {
        MAIN <- paste0(deparse(substitute(list(...))), collapse = " ")
        MAIN <- substring(MAIN, 6, nchar(MAIN) - 1)
    }
    else MAIN <- title
    p <- 
        xyplot(active ~ date, data = fm, col = 1, type = "l",
               main = MAIN,
               subset = if (is.null(drop.before)) TRUE else date >= as.Date(drop.before),
               key = list(text = list(predict.at, col = 1 + seq_along(predict.at), cex = 0.8),
                          lines = list(type = "l", col = 1 + seq_along(predict.at)),
                          title = "Prediction date",
                          cex.title = 1,
                          ## space = #"inside",
                          x = 0, y = 1,
                          corner = c(0, 1)),
               scales = list(y = list(rot = 0)),
               grid = TRUE)
    TO <- tail(fm$date, 1)
    predict.at <- as.Date(predict.at)
    for (i in seq_along(predict.at))
    {
        at <- predict.at[i]
        pfm <- predict(fm, days = min(as.numeric(TO - at), max.predict),
                       ## method = "active",
                       plag = plag,
                       from = at, linear = linear)
        p <- p + xyplot(active ~ date, data = pfm, subset = date > at,
                        type = "o", col = i+1, pch = ".", cex = 3)
    }
    update(c(p, q, x.same = TRUE, layout = c(1, 2)),
           ylab = list(expression(hat(lambda)(t) - mu, "Active cases"),
                       y = c(1/6, 2/3)),
           between = list(y = 0.5),
           plot.args = list(panel.height = list(x = c(6, 3), unit = "null")))
}



days2critical <- 
    function(object, target = NULL,
             days = 100, from = NULL,
             ...)
{
    ## Algorithm: predict from 'from' to next 'days' days.
    ##   If first estimate > target, return 0
    ##   If any(e > target), return which(e > target)[1]
    ##   else return NA

    d <- subset(predict(object, days = 3 * days, from = from, ...),
                date > from)
    a <- d$active
    ans <- 
        if (anyNA(a) || all(a < target))
            NA
        else which(a >= target)[1]
    ans[ans > days] <- days
    ans
}






predictCriticalByZone <-
    function(data, ..., target, days = 100,
             lag = 7, mu = 1/10, smooth = FALSE,
             drop.before = NULL,
             linear = FALSE,
             adjust = TRUE,
             rate.smooth = 4,
             plag = lag)
{
    d <- aggregate.data(dall, ...)
    fm <- estimate.growth(d, lag = lag, mu = mu, smooth = smooth)
    fm$days2critical <- NA
    for (i in tail(seq_len(nrow(fm)), -(2*lag+1)))
    {
        if (is.finite(fm$lambda2[i]))
        {
            fm$days2critical[i] <-
                days2critical(fm, target = target,
                              days = days, from = fm$date[i],
                              linear = linear,
                              adjust = adjust,
                              rate.smooth = rate.smooth,
                              plag = plag,
                              ...)
        }
    }
    MAIN <- paste0(deparse(substitute(list(...))), collapse = " ")
    MAIN <- substring(MAIN, 6, nchar(MAIN) - 1)
    mapcolor <- function(v, ncol = 10) # v between 0 and days
    {
        i <- 1 + round((ncol-1) * (v - 0) / days)
        stopifnot(all(i <= ncol))
        hcl.colors(10, palette = "Red-Green")[i]
    }
    p <- 
        levelplot(days2critical ~ date + days2critical, data = fm, type = "p", cex = 0.5,
                  panel = panel.levelplot.points,
                  subset = if (is.null(drop.before)) TRUE else date >= as.Date(drop.before),
                  grid = TRUE)
    q <-
        xyplot(lambda2 - 0.1 ~ date, data = fm, type = "l",
               subset = if (is.null(drop.before)) TRUE else date >= as.Date(drop.before),
               abline = list(h = 0, col = "grey", lwd = 3),
               grid = TRUE)
    r <- 
        xyplot(active ~ date, data = fm, type = "l",
               subset = if (is.null(drop.before)) TRUE else date >= as.Date(drop.before),
               scales = list(y = list(rot = 0)),
               abline = list(h = target, col = adjustcolor("red", alpha.f = 0.2), lwd = 3),
               grid = TRUE)
    update(c(r, p, q, x.same = TRUE, layout = c(1, 3)),
           main = MAIN,
           ylab = expression(hat(lambda)(t) - mu, "Days to critical", "Active"),
           between = list(y = 0.5))
}




if (FALSE)
{


## testing

library(lattice)
library(latticeExtra)

TARGET <- "districts.csv"
dall <- read.csv(TARGET)
dall <-
    within(dall,
    {
        Date  <- as.Date(Date)
    })

d <- aggregate.data(dall, state = "Delhi")

r <- estimate.growth(d, lag = 7)

xyplot(rho + 10*lambda1 + 10*lambda2 ~ date, data = r, type = "l",
       auto.key = list(lines = TRUE, points = FALSE),
       grid = TRUE)

xyplot(active ~ date, data = r, type = "l",
       ## auto.key = list(lines = TRUE, points = FALSE),
       grid = TRUE)


predict(r, days = 30, from = "2021-04-01")


## method = rho (increment ratio)

xyplot(active ~ date, data = predict(r, days = 30, from = "2021-04-01"),
       type = "l", col = 2)

## weird spikes and falls, so check calculations
xyplot(active ~ date, data = r, type = "l", subset = date > as.Date("2021-01-01"),
       ## auto.key = list(lines = TRUE, points = FALSE),
       grid = TRUE) +
    xyplot(active ~ date, data = predict(r, days = 30, method = "increment", from = "2021-04-01"),
           type = "o", col = 2, pch = ".", cex = 3)


xyplot(confirmed ~ date, data = r, type = "l", subset = date > as.Date("2021-01-01"),
       ## auto.key = list(lines = TRUE, points = FALSE),
       grid = TRUE) +
    xyplot(confirmed ~ date, data = predict(r, days = 30, method = "increment", from = "2021-04-01"),
           type = "o", col = 2, pch = ".", cex = 3)
    


## method = lambda2 (active-based, similar to increment ratio)

xyplot(active ~ date, data = r, type = "l", subset = date > as.Date("2021-01-01"),
       ## auto.key = list(lines = TRUE, points = FALSE),
       grid = TRUE) +
    xyplot(active ~ date, data = predict(r, days = 30, method = "active", from = "2021-04-01"),
           type = "o", col = 2, pch = ".", cex = 3)


xyplot(active ~ date, data = r, type = "l", subset = date > as.Date("2021-01-01"),
       ## auto.key = list(lines = TRUE, points = FALSE),
       grid = TRUE) +
    xyplot(active ~ date, data = predict(r, days = 45, method = "active", from = "2021-03-15"),
           type = "o", col = 2, pch = ".", cex = 3)



xyplot(active ~ date, data = r, type = "l", subset = date > as.Date("2021-01-01"),
       ## auto.key = list(lines = TRUE, points = FALSE),
       grid = TRUE) +
    xyplot(active ~ date, data = predict(r, days = 60, method = "active", from = "2021-03-01"),
           type = "o", col = 2, pch = ".", cex = 3)


## method = lambda1 (confirmed-based)

## again weird spikes - probably due to noise in confirmed - smoothing may help
xyplot(active ~ date, data = r, type = "l", subset = date > as.Date("2021-01-01"),
       ## auto.key = list(lines = TRUE, points = FALSE),
       grid = TRUE) +
    xyplot(active ~ date, data = predict(r, days = 30, method = "confirmed", from = "2021-04-01"),
           type = "o", col = 2, pch = ".", cex = 3)




xyplot(confirmed ~ date, data = r, type = "l", subset = date > as.Date("2021-01-01"),
       ## auto.key = list(lines = TRUE, points = FALSE),
       grid = TRUE) +
    xyplot(confirmed ~ date, data = predict(r, days = 30, method = "confirmed", from = "2021-04-01"),
           type = "o", col = 2, pch = ".", cex = 3)


predictZone(dall, state = "Delhi", lag = 7, mu = 1/10, drop.before = NULL)

predictZone(dall, state = "Delhi", lag = 7, mu = 1/10,
            drop.before = "2020-10-01", smooth = FALSE)

predictZone(dall, state = "Delhi", lag = 7, mu = 1/10,
            drop.before = "2020-10-01", smooth = 10)


predictZone(dall, district = "Mumbai", lag = 7, mu = 1/10, drop.before = "2020-10-01")

predictZone(dall, state = "Maharashtra", lag = 7, mu = 1/10, drop.before = "2020-10-01")

predictZone(dall, state = "Karnataka", lag = 7, mu = 1/10, drop.before = "2020-10-01")

predictZone(dall, district = "Kolkata", lag = 7, mu = 1/10, drop.before = "2020-10-01")

predictZone(dall, state = "Kerala", lag = 7, mu = 1/10, drop.before = "2020-10-01",
            predict.at = c("2021-03-01", "2021-03-15", "2021-04-01", "2021-04-08"))

    predictCriticalByZone(dall, state = "Delhi", lag = 7, mu = 1/10,
                          drop.before = "2020-06-01", linear = TRUE,
                          target = 20000)



}
