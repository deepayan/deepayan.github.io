
library(lattice)
library(latticeExtra)

deaths <- read.csv("../time_series_covid19_deaths_global.csv",
                   check.names = FALSE, stringsAsFactors = FALSE)

## top 10 countries
NCOL <- length(deaths)
deaths <- deaths[order(deaths[[NCOL]], decreasing = TRUE), ]

top.deaths <- head(deaths, 8)

top.deaths.weekly <- data.matrix(top.deaths[ , seq(to = NCOL, by = 7, length.out = 12)])
rownames(top.deaths.weekly) <-
    with(top.deaths, paste0(ifelse(`Province/State` == "", `Country/Region`,
                                   paste(`Country/Region`, `Province/State`,
                                         sep = "/")),
                            "(", top.deaths.weekly[, ncol(top.deaths.weekly)], ")"))
         
top.deaths.weekly

top.deaths.weekly <- t(apply(top.deaths.weekly, 1, diff))
top.deaths.weekly

panel.glabel <- function(x, y, group.value, col.symbol, ...) # x,y vectors; group.value scalar
{
    n <- length(x)
    panel.text(x[n], y[n] + (y[n] < 1000) * runif(1, -500, 500),
               label = group.value, pos = 4, col = col.symbol, srt = 0)
}


png("weekly-deaths.png", width = 0.75 * 1600, height = 0.75 * 900)

set.seed(2018)

dotplot(t(top.deaths.weekly), auto.key = FALSE, horizontal = FALSE,
        type = "o", pch = 16, xlim = c(colnames(top.deaths.weekly), "", ""),
        ## scales = list(y = list(log = 10, equispaced.log = FALSE)),
        xlab = "Week ending on", ylab = "Weekly number of deaths") +
    glayer_(panel.glabel(x, y, group.value = group.value, ...))

dev.off()
