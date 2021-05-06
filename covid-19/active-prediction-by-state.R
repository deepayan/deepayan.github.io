STATE <- "West Bengal"

## use growth model to make short term predictions for all districts within a state

## setup

library(lattice)
library(RColorBrewer)
library(latticeExtra)
bdark <- RColorBrewer::brewer.pal(n = 8, name = "Dark2")
palette(c("black", bdark))
ct <- custom.theme(symbol = bdark, fill = adjustcolor(bdark, alpha.f = 0.5))
ct$strip.background$col <- "grey90"
ct$strip.border$col <- "grey50"
ct$axis.line$col <- "grey50"
lattice.options(default.theme = ct, default.args = list(as.table = TRUE))

source("prediction-utils.R")

TARGET <- "districts.csv"
## To download the latest version, delete the file and run again
if (!file.exists(TARGET))
    download.file("https://api.covid19india.org/csv/latest/districts.csv",
                  destfile = TARGET)
dall <- read.csv(TARGET)
dall <-
    within(dall,
    {
        Date  <- as.Date(Date)
    })
LAG <- 7
MU <- 1/10
START <- "2021-01-01"
PREDICT.AT <- c("2021-03-03", "2021-03-17", "2021-03-31", "2021-04-06")

predictAndPlot <- function(...)
{
    predictZone(dall, ..., lag = LAG, mu = MU,
                drop.before = START, linear = TRUE,
                predict.at = PREDICT.AT)
}

dsub <- subset(dall, State == STATE)
latest <- subset(dsub, Date == max(Date))
districts <- with(latest, District[order(Confirmed - Recovered - Deceased, decreasing = TRUE)])
districts <- districts[districts != "Other State"]


pdf(file = paste0(gsub(" ", "_", STATE, fixed = TRUE),
                  "-predictions.pdf"),
    height = 8, width = 11)


for (d in districts)
{
    message(d)
    print(predictAndPlot(district = d, title = d))
}

dev.off()
