---
layout: post
title: 'Doubling times of COVID-19 cases'
author: Deepayan Sarkar
markdown: GFM
---


Data source: <https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series>




Is "social distancing" working in your country? How is it doing
compared to other countries? How long will it take for the number of
cases to reach 50,000? Or 100,000?

This is an attempt to summarize how successfully various countries /
regions are containing the spread COVID-19, based on a very simple
summary statistic: how long it is taking to double the number of
cases, and how this "doubling time" changes over time.

The analysis is based on the official number of _confirmed_ cases,
based on data provided by [JHU
CSSE](https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series)
on Github. Not all countries are testing equally aggressively (e.g.,
India), so these numbers may not reflect the actual number of
cases. In the long run though, that does not matter as long as the
_proportion_ of true cases being detected remains more or less stable.

Here is the [source](doubling.rmd) of this analysis, in case you want
to experiment with it.


## Preparatory steps

First, download the data if not done already (to download the latest
version, delete the file and run again):


```r
TARGET <- "time_series_19-covid-Confirmed.csv"
if (!file.exists(TARGET))
    download.file("https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv",
                  destfile = TARGET)
```

This version was last updated using data downloaded on 2020-03-23.


Next, read in data:


```r
covid <- read.csv(TARGET, check.names = FALSE,
                  stringsAsFactors = FALSE)
```

Many of the high numbers are provinces in China, where spread is now
more or less controlled. We consider them separately. Data for the US
is also available separately by state, and we consider them separately
as well. We exclude cases on cruise ships, which represent small
populations.



```r
covid.china <- subset(covid, `Country/Region` == "China")
covid.usa <- subset(covid, `Country/Region` == "US")
covid.row <- subset(covid, !(`Country/Region` %in%
                             c("China", "US", "Cruise Ship")))
```

Next, we extract the time series data of each subset as a data matrix,
with a crude "smoothing" to account for lags in updating data: If two
consecutive days have the same total count followed by a large
increase on the following day, then the most likely explanation is
that data was not updated on the second day. In such cases, the count
of the middle day is replaced by the geometric mean of its neighbours.



```r
correctLag <- function(x)
{
    n <- length(x)
    stopifnot(n > 2)
    for (i in seq(2, n-1))
        if (x[i] == x[i-1])
            x[i] <- sqrt(x[i-1] * x[i+1])
    x
}
extractCasesTS <- function(d)
{
    x <- t(data.matrix(d[, -c(1:4)]))
    colnames(x) <-
        with(d, ifelse(`Province/State` == "",
                       `Country/Region`,
                       paste(`Country/Region`, `Province/State`,
                             sep = "/")))
    ## Update labels to include current total cases
    colnames(x) <-  sprintf("%s (%g)", colnames(x), x[nrow(x), ])
    apply(x, 2, correctLag)
}
xcovid.china <- extractCasesTS(covid.china)
xcovid.usa <- extractCasesTS(covid.usa)
xcovid.row <- extractCasesTS(covid.row)
```

Outside the US and China, which countries are the worst affected in
terms of the latest absolute numbers so far?


```r
total.row <- sort(apply(xcovid.row, 2, tail, 1))
dotplot(total.row[ total.row > 199 ],
        xlab = "Total cases (NOTE: log scale)",
        scales = list(x = list(alternating = 3, log = TRUE,
                               equispaced.log = FALSE)))
```

![plot of chunk unnamed-chunk-5](figures/doubling-unnamed-chunk-5-1.png)
\


