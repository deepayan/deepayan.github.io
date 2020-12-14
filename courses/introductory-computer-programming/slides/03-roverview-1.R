opts_chunk$set(cache = TRUE, cache.path='~/knitr-cache/icp-roverview-1/', autodep = TRUE,
               comment = "", warning = TRUE, message = TRUE,
               knitr.table.format = "html",
               fig.width = 15, fig.height = 6,
               dpi = 96, fig.path='figures/roverview-1-')
options(warnPartialMatchDollar = FALSE, width = 100)

34 * 23
27 / 7
exp(2)
2^10

sqrt(5 * 125)
log(120)
factorial(10)
log(factorial(10))

choose(15, 5)
factorial(15) / (factorial(10) * factorial(5))

choose(1500, 2)
factorial(1500) / (factorial(1498) * factorial(2))

x <- 2
y <- 10
x^y
y^x
factorial(y)
log(factorial(y), base = x)

N <- 15
x <- seq(0, N)
N
x
choose(N, x)

p <- 0.25
choose(N, x) * p^x * (1-p)^(N-x)
dbinom(x, size = N, prob = p)

p.x <- dbinom(x, size = N, prob = p)
sum(x * p.x) / sum(p.x)
N * p

plot(x, p.x, ylab = "Probability", pch = 16)
title(main = sprintf("Binomial(%g, %g)", N, p))
abline(h = 0, col = "grey")

cards <- as.vector(outer(c("H", "D", "C", "S"), 1:13, paste))
cards

sample(cards, 13)
sample(cards, 13)

z <- rnorm(50, mean = 0, sd = 1)
z

plot(1:100, type = "n", ylim = c(-25, 25), ylab = "")
for (i in 1:20) {
    z <- rnorm(100, mean = 0, sd = 1)
    lines(cumsum(z), col = sample(colors(), 1))
}
