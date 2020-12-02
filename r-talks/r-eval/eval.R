library(knitr)
opts_chunk$set(cache = FALSE, autodep = TRUE,
               comment = "", warning = TRUE, message = TRUE, prompt = FALSE,
               dev.args = list(pointsize = 16),
               fig.width = 15, fig.height = 6, dpi = 96, fig.path='figures/eval-')
options(warnPartialMatchDollar = FALSE, width = 100)
set.seed(20191105)

sqrt(x)

find("sqrt")
find("x") # not found

x <- 10
sqrt(x)
x <- -1
sqrt(x)

x <- -1+0i
sqrt(x)
x <- "-1"
sqrt(x)

find("sqrt")
find("x")

sqrt

sqrt <- function(x)
{
    orig.sqrt <- .Primitive("sqrt")
    if (is.character(x)) x <- as.numeric(x)
    if (is.numeric(x) && any(x < 0)) x <- complex(real = x, imaginary = 0)
    orig.sqrt(x)
}

x <- -1
sqrt(x)

find("x")
find("sqrt")

search()

e <- .GlobalEnv
while (TRUE) { str(e, give.attr = FALSE); e <- parent.env(e) }
search() # compare

e1 <- new.env()
e1$x <- seq(0, 2 * pi, length.out = 101)
e1$y <- cos(e1$x)
plot(y ~ x, data = e1, type = "l", ylim = c(-1, 1))

e2 <- e1
range(e1$y)
e2$y <- abs(e2$y)
range(e1$y) # changes even though e1$y has not been directly modified 

ls(e2)
ls.str(e2) ## summary of all objects in e2

environment(sqrt)
environment(base::sqrt) # special "primitive" (C) function, so no environment
environment(hist)

boxcox <- function(x) # applies Box-Cox transformation on data 'x'
{
	if (lambda == 0) log(x)
	else (x^lambda - 1) / lambda
}
b <- function(x) # computes histogram bins given data 'x' 
{
    n <- sum(is.finite(x))
    r <- extendrange(x)
    seq(r[1], r[2], length.out = round(sqrt(n))+1)
}

x <- rlnorm(1000)
hist(boxcox(x), breaks = b)

lambda <- 0
hist(boxcox(x), breaks = b)  # notice that 'b' is a function! (See ?hist)

fboxcox <- function(lambda)
{
	f <- function(x)
	{
		if (lambda == 0) log(x)
		else (x^lambda - 1) / lambda
	}
    return(f)
}

boxcox.sqrt <- fboxcox(0.5)
boxcox.log <- fboxcox(0)

par(mfrow = c(1, 2))
hist(boxcox.sqrt(x), breaks = b)
hist(boxcox.log(x), breaks = b)

boxcox.sqrt
boxcox.log

environment(boxcox.sqrt)
environment(boxcox.log)

ls.str(environment(boxcox.sqrt))
ls.str(environment(boxcox.log))

y <- 123
f <- function(x) {
    y <- x * x
	g <- function() print(y)
	g()
}
f(10)

ECDF <- function(x)
{
	x <- x[is.finite(x)]
	function(u) {
	    sum(x <= u) / length(x)
	}
}
x <- rlnorm(50)
F.sqrt <- ECDF(boxcox.sqrt(x))
F.log <- ECDF(boxcox.log(x))

sapply(-5:5, F.sqrt)
sapply(-5:5, F.log)

FF.log <- Vectorize(F.log)
plot(FF.log, from = -4, to = 4, n = 1000)

F.log

environment(F.log)$x

make.objective <- function(x, y, L = abs)
{
	function(beta) {
	    sum(L(y - beta[1] - beta[2] * x))
	}
}
data(phones, package = "MASS")
obj.lad <- with(phones, make.objective(year, calls, L = abs))
obj.lse <- with(phones, make.objective(year, calls, L = function(u) u*u))

obj.lad
environment(obj.lse)$L
environment(obj.lad)$L

fm.lad <- optim(obj.lad, par = c(0,0))
fm.lse <- optim(obj.lse, par = c(0,0))
str(fm.lad)
str(fm.lse)

plot(calls ~ year, phones)
abline(fm.lad$par, col = "blue")
abline(fm.lse$par, col = "red")

chooseBins <- function(x, p = 0.25)
{
    x <- x[is.finite(x)]
    n <- length(x)
    r <- extendrange(x)
    d <- r[2] - r[1]
    CVE <- function(B)
    {
        h <- d / B
        breaks <- seq(r[1], r[2], length.out = B+1)
        k <- findInterval(x, breaks) # runtime O(n * log(B))
        counts <- table(factor(k, levels = 1:B))
        2 / ((n-1)*h) - sum(counts^2) * (n+1) / ((n-1) * n^2 * h)
    }
    Bvec <- seq(floor(sqrt(n)*p), ceiling(sqrt(n)/p))
    list(range = r, B = Bvec, CVE = unname(sapply(Bvec, CVE)))
}

xx <- c(rnorm(500), rnorm(300, mean = 6, sd = 1.5))
ll <- chooseBins(xx, p = 0.125)
str(ll)

with(ll, {
    plot(CVE ~ B, type = "o")
    abline(v = B[which.min(CVE)])
})

(nclass.cv <- with(ll, B[which.min(CVE)]))
nclass.Sturges(xx)
nclass.FD(xx)
nclass.scott(xx)

breaks <- seq(ll$range[1], ll$range[2], length.out = nclass.cv + 1)
hist(xx, breaks = breaks)

rm(list = c("x", "y")) # remove x, y if defined earlier
plot(x, y, type = "l")

e <- quote(plot(x, y, type = "l"))
e
e[[1]]
e[[2]]
e[[3]]

eval(e)

ls.str(e2)

eval(e, envir = e2)

my.replicate <- function(N, e)
{
    ans <- numeric(N)
    for (i in 1:N) ans[[i]] <- eval(e)
    ans
}

my.replicate(5, max(rnorm(10))) # not what we wanted
my.replicate(5, quote(max(rnorm(10))))

my.replicate <- function(N, e)
{
    expr <- substitute(e) # avoids the need to quote()
    ans <- numeric(N)
    for (i in 1:N) ans[[i]] <- eval(expr)
    ans
}
str(x <- my.replicate(1000, max(rnorm(20))))

set.seed(20191105)
rm(sqrt) # remove the sqrt() we defined earlier
chooseOne <- function(a, b, u = runif(1))
{
    if (u < 0.5) a else b
}
chooseOne(sqrt(2), sqrt(-2)) # no warning message
chooseOne(sqrt(2), sqrt(-2)) # warning message

## ? environment
## ? eval
## ? expression
## ? quote
## ? bquote
## ? substitute
## ? with

with.default
replicate
