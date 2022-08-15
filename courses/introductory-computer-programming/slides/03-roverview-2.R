opts_chunk$set(cache = TRUE, cache.path='~/knitr-cache/icp-roverview-2/', autodep = TRUE,
               comment = "", warning = TRUE, message = TRUE,
               knitr.table.format = "html",
               fig.width = 15, fig.height = 7, dpi = 96, fig.path='figures/roverview-2-')
library(lattice)
lattice.options(default.args = list(as.table = TRUE), 
                default.theme = list(grid.pars = list(cex = 1.5)))
options(warnPartialMatchDollar = FALSE, width = 120)

NN <- 18 + 8 # total
XX <- 18     # white and gold

N = NN
x = XX
p = 0.5
choose(N, x) * p^x * (1-p)^(N-x)

pvec = seq(0, 1, by = 0.01)
pvec
Lvec = choose(N, x) * pvec^x * (1-pvec)^(N-x)
Lvec

plot(x = pvec, y = Lvec, type = "l")

L = function(p) choose(N, x) * p^x * (1-p)^(N-x)
L(0.5)
L(x/N)

plot(L, from = 0, to = 1)

optimize(L, interval = c(0, 1), maximum = TRUE)

XX / NN

data(Davis, package = "carData")        # Davis height and weight data
str(Davis)                              # Summarize structure of data
fm <- lm(weight ~ height, data = Davis) # Regression of weight on height
fm

library(lattice) # A different way to plot data
xyplot(weight ~ height, data = Davis, grid = TRUE, type = c("p", "r"))

coef(fm) # estimated regression coefficients

SSE = function(beta)
{
    with(Davis,
         sum((weight - beta[1] - beta[2] * height)^2))
}
optim(c(0, 0), fn = SSE)

summary(fm)

SAE = function(beta)
{
    with(Davis,
         sum(abs(weight - beta[1] - beta[2] * height)))
}
opt = optim(c(0, 0), fn = SAE)
opt

xyplot(weight ~ height, data = Davis, grid = TRUE,
       panel = function(x, y, ...) {
           panel.abline(fm, col = "red") # squared errors
           panel.abline(opt$par, col = "blue") # absolute errors
           panel.xyplot(x, y, ...)
       })

library(ggplot2)
qplot(x = height, y = weight, data = Davis) + 
	    geom_abline(intercept = coef(fm)[1], slope = coef(fm)[2], col = 2) + 
        geom_abline(intercept = opt$par[1], slope = opt$par[2], col = 3)

## library(plotly)
## ggplotly(qplot(x = height, y = weight, data = Davis) +
## 	       geom_abline(intercept = coef(fm)[1], slope = coef(fm)[2], col = 2) +
##            geom_abline(intercept = opt$par[1], slope = opt$par[2], col = 3))

library(plotly)
w <- ggplotly(qplot(x = height, y = weight, data = Davis) + 
              geom_abline(intercept = coef(fm)[1], slope = coef(fm)[2], col = 2) + 
              geom_abline(intercept = opt$par[1], slope = opt$par[2], col = 3))
htmlwidgets::saveWidget(w, "davis-plotly.html", selfcontained = FALSE, 
                        libdir = "plotly-files")

N <- 28
days <- sample(365, N, rep = TRUE)
days
length(unique(days))

haveCommon <- function()
{
    days = sample(365, N, rep = TRUE)
    length(unique(days)) < N
}
haveCommon()
haveCommon()
haveCommon()
haveCommon()

replicate(100, haveCommon())

plot(cumsum(replicate(1000, haveCommon())) / 1:1000, type = "l", ylim = c(0.5, 1))
lines(cumsum(replicate(1000, haveCommon())) / 1:1000, col = "red")
lines(cumsum(replicate(1000, haveCommon())) / 1:1000, col = "blue")
