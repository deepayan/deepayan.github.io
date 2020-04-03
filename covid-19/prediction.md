---
layout: default
title: 'Predicting COVID-19 cases'
author: Deepayan Sarkar
---








[This note was last updated using data downloaded on 
2020-04-03. Here is the
[source](prediction.rmd) of this analysis. Click <a href="#"
data-toggle="collapse" data-target="div.sourceCode"
aria-expanded="true">here</a> to show / hide the R code used. ]


Prediction is of course
[difficult](https://quoteinvestigator.com/2013/10/20/no-predict/),
especially about the future.

As we see [here](doubling.html), a plot of the case counts today, one
week ago, and two weeks ago gives us a good sense of how different
countries are managing the spread of COVID-19. The following plot is
similar, showing the latest counts, and also shows how much the counts
have increased in the last 4 days, and the 4 days before that. These
are on a logarithmic scale, which means that the 4-day increases are a
measure of the percentage increase; larger means faster rate of
growth.



```r
total.row <- apply(xcovid.row, 2, tail, 1)
total.row.1 <- apply(xcovid.row, 2, function(x) tail(x, 5)[1])
total.row.2 <- apply(xcovid.row, 2, function(x) tail(x, 9)[1])
torder <- tail(order(total.row), 60)
dotplot(total.row[torder], total.1 = total.row.1[torder], total.2 = total.row.2[torder],
        xlab = "Total cases (NOTE: log scale)",
        xlim = c(100, NA),
        panel = function(x, y, ..., total.1, total.2, col) {
            col <- trellis.par.get("superpose.line")$col
            dot.line <- trellis.par.get("dot.line")
            panel.abline(h = unique(y), col = dot.line$col, lwd = dot.line$lwd)
            panel.segments(log10(total.2), y, log10(total.1), y, col = col[3], lwd = 2)
            panel.segments(log10(total.1), y, x, y, col = col[2], lwd = 3)
            panel.points(x, y, pch = 16, col = col[1])
        },
        scales = list(x = list(alternating = 3, log = 10, equispaced.log = FALSE)))
```

![plot of chunk unnamed-chunk-2](figures/prediction-unnamed-chunk-2-1.png)

We can use this for a crude prediction of the number of cases 4 days
further on, by assuming that on the log scale, the "increase" changes
(actually decreases, one hopes) in a geometric progression. The
countries are sorted according to their case counts 4 days ago. 


```r
predictCases <- function(x, days = 7, go.back = TRUE)
    ## go.back = TRUE: use -days, -2*days to predict current
    ## go.back = FALSE: use -days, current to predict +days
{
    u <- if (go.back) head(x, -days) else x # used for prediction
    N <- nrow(u)
    if (N - 2 * days > nrow(x)) stop("Not enough data")
    if (any(u[N - 2 * days, ] == 0))
    {
        warning("dropping zero counts at %g days for %s", N - 2 * days)
        keep <- u[N - 2 * days, ] > 0
        u <- u[, keep, drop = FALSE]
        x <- x[, keep, drop = FALSE]
    }
    total.0 <- u[N, , drop = TRUE]
    total.1 <- u[N - days, , drop = TRUE]
    total.2 <- u[N - 2 * days, , drop = TRUE]
    ## predict assuming linear change in diff(log(count))
    d2 <- log(total.1) - log(total.2)
    d1 <- log(total.0) - log(total.1)
    ## assume these are in geometric progression
    ## d0 <- d1 * d1 / d2
    ## or assume these are in arithmetic progression (can go negative)
    d0 <- 2 * d1 - d2
    total.predict <- exp(log(total.0) + d0)
    total.observed <- if (go.back) x[N + days, , drop = TRUE] else NA
    data.frame(region = colnames(x),
               total2 = total.2,
               total1 = total.1,
               total0 = total.0,
               predicted = total.predict,
               observed = total.observed)
}
```

This is how well these predictions performed when applied on data from
4 days ago to predict the current counts (for the 30 countries with
highest current count). The predictions are sometimes bad when counts
are low (not surprisingly), but generally reasonable.



```r
torder <- tail(order(total.row), 30)
pred.past <- predictCases(xcovid.row[, torder, drop = FALSE], days = 4, go.back = TRUE)
dotplot(reorder(region, total0) ~ predicted + observed, data = pred.past,
        xlab = "Predicted current number of cases based on data four days ago",
        par.settings = simpleTheme(pch = 16, col = c(1, 2)), auto.key = list(columns = 2),
        scales = list(x = list(log = TRUE, equispaced.log = FALSE)))
```

![plot of chunk unnamed-chunk-4](figures/prediction-unnamed-chunk-4-1.png)

Here are the predictions 4 days into the future (
2020-04-07
) using current data.


```r
torder <- tail(order(total.row), 60)
pred.current <- predictCases(xcovid.row[, torder, drop = FALSE], days = 4, go.back = FALSE)
plot.col <- trellis.par.get("plot.symbol")$col
with(pred.current,
     dotplot(reorder(region, predicted) ~ total0,
             predicted = predicted,
             xlab = sprintf("Predicted number of cases as on %s",
                            as.Date(file.mtime(TARGET)) + 4),
             xlim = c(NA, exp(1.07 * max(log(predicted)))),
             par.settings = simpleTheme(pch = c(16, 1), col = plot.col), 
             panel = function(x, y, ..., predicted) {
                 dot.line <- trellis.par.get("dot.line")
                 panel.abline(h = unique(y), col = dot.line$col, lwd = dot.line$lwd)
                 panel.points(x, y, ...)
                 panel.points(log10(predicted), y, pch = 1, ...)
                 panel.text(current.panel.limits()$xlim[2],
                            y, labels = round(predicted), pos = 2)
             },
             auto.key = list(columns = 2, text = c("current", "predicted")),
             scales = list(x = list(log = 10, equispaced.log = FALSE))))
```

![plot of chunk unnamed-chunk-5](figures/prediction-unnamed-chunk-5-1.png)

