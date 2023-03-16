---
title: RFC - Enhancing tapply
author: Deepayan Sarkar
---





# Motivation

For group-wise summaries of a data frame, `dplyr` can do the following.

- Several scalar-valued functions


```r
ToothGrowth |> group_by(supp, dose) |>
    summarize(m = mean(len), s = sd(len), n = length(len))
```

```
# A tibble: 6 x 5
# Groups:   supp [2]
  supp   dose     m     s     n
  <fct> <dbl> <dbl> <dbl> <int>
1 OJ      0.5 13.2   4.46    10
2 OJ      1   22.7   3.91    10
3 OJ      2   26.1   2.66    10
4 VC      0.5  7.98  2.75    10
5 VC      1   16.8   2.52    10
6 VC      2   26.1   4.80    10
```

- Scalar valued functions with vector input


```r
ToothGrowth |> group_by(supp) |>
    summarize(mlen = mean(len), mdose = mean(dose),
              slope = coef(lm(len ~ log(dose)))[[2]])
```

```
# A tibble: 2 x 4
  supp   mlen mdose slope
  <fct> <dbl> <dbl> <dbl>
1 OJ     20.7  1.17  9.25
2 VC     17.0  1.17 13.1 
```

- Vector valued functions with scalar / vector input


```r
ToothGrowth |> group_by(supp) |>
    summarize(data.frame(mlen = mean(len), slen = sd(dose)),
              as.data.frame(as.list(coef(lm(len ~ log(dose))))))
```

```
# A tibble: 2 x 5
  supp   mlen  slen X.Intercept. log.dose.
  <fct> <dbl> <dbl>        <dbl>     <dbl>
1 OJ     20.7 0.634         20.7      9.25
2 VC     17.0 0.634         17.0     13.1 
```

But this means that we have to have convoluted code for something like


```r
ToothGrowth |> group_by(supp, dose) |>
    summarize(data.frame(as.list(quantile(len))))
```

```
# A tibble: 6 x 7
# Groups:   supp [2]
  supp   dose   X0.  X25.  X50.  X75. X100.
  <fct> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
1 OJ      0.5   8.2  9.7  12.2   16.2  21.5
2 OJ      1    14.5 20.3  23.5   25.6  27.3
3 OJ      2    22.4 24.6  26.0   27.1  30.9
4 VC      0.5   4.2  5.95  7.15  10.9  11.5
5 VC      1    13.6 15.3  16.5   17.3  22.5
6 VC      2    18.5 23.4  26.0   28.8  33.9
```

because the simpler option doesn't work.


```r
ToothGrowth |> group_by(supp, dose) |> summarize(quantile(len))
```

```
Warning: Returning more (or less) than 1 row per `summarise()` group was deprecated in dplyr 1.1.0.
ℹ Please use `reframe()` instead.
ℹ When switching from `summarise()` to `reframe()`, remember that `reframe()` always returns an ungrouped data frame and adjust accordingly.
[90mCall `lifecycle::last_lifecycle_warnings()` to see where this warning was generated.[39m
```

```
# A tibble: 30 x 3
# Groups:   supp, dose [6]
   supp   dose `quantile(len)`
   <fct> <dbl>           <dbl>
 1 OJ      0.5             8.2
 2 OJ      0.5             9.7
 3 OJ      0.5            12.2
 4 OJ      0.5            16.2
 5 OJ      0.5            21.5
 6 OJ      1              14.5
 7 OJ      1              20.3
 8 OJ      1              23.5
 9 OJ      1              25.6
10 OJ      1              27.3
# … with 20 more rows
```

Another interesting example is where the input data frame is
summarized in some way, but not to scalars. Let's say order by first
column and then take first 3 rows.



```r
mySummary <- function(d)
{
    ## could also use dplyr::rearrange() instead
    o <- order(d[[1]])
    head(d[o, ], 3)
}
```



```r
ToothGrowth |> group_by(supp) |>
    summarize(mlen = mean(len), 
              mySummary(data.frame(len = len, dose = dose)))
```

```
Warning: Returning more (or less) than 1 row per `summarise()` group was deprecated in dplyr 1.1.0.
ℹ Please use `reframe()` instead.
ℹ When switching from `summarise()` to `reframe()`, remember that `reframe()` always returns an ungrouped data frame and adjust accordingly.
[90mCall `lifecycle::last_lifecycle_warnings()` to see where this warning was generated.[39m
```

```
# A tibble: 6 x 4
# Groups:   supp [2]
  supp   mlen   len  dose
  <fct> <dbl> <dbl> <dbl>
1 OJ     20.7   8.2   0.5
2 OJ     20.7   9.4   0.5
3 OJ     20.7   9.7   0.5
4 VC     17.0   4.2   0.5
5 VC     17.0   5.2   0.5
6 VC     17.0   5.8   0.5
```

This was OK with `dplyr_1.0.2`, but deprecated in `dplyr_1.1.0`.

What are closest equivalents with base R?

# split

Very general, but needs manual post-processing


```r
s1 <- split(ToothGrowth, ~ supp + dose)
lapply(s1, with, data.frame(supp = unique(supp),
                            dose = unique(dose),
                            m = mean(len),
                            s = sd(len),
                            n = length(len))) |>
    do.call(what = rbind)
```

```
       supp dose     m        s  n
OJ.0.5   OJ  0.5 13.23 4.459709 10
VC.0.5   VC  0.5  7.98 2.746634 10
OJ.1     OJ  1.0 22.70 3.910953 10
VC.1     VC  1.0 16.77 2.515309 10
OJ.2     OJ  2.0 26.06 2.655058 10
VC.2     VC  2.0 26.14 4.797731 10
```

```r
s2 <- split(ToothGrowth, ~ supp)
lapply(s2, with, data.frame(supp = unique(supp),
                            mlen = mean(len),
                            mdose = mean(dose),
                            slope = coef(lm(len ~ log(dose)))[[2]])) |>
    do.call(what = rbind)
```

```
   supp     mlen    mdose     slope
OJ   OJ 20.66333 1.166667  9.254889
VC   VC 16.96333 1.166667 13.099671
```

```r
lapply(s2, with, data.frame(supp = unique(supp),
                            mlen = mean(len),
                            slen = sd(dose),
                            as.list(coef(lm(len ~ log(dose)))))) |>
    do.call(what = rbind)
```

```
   supp     mlen      slen X.Intercept. log.dose.
OJ   OJ 20.66333 0.6342703     20.66333  9.254889
VC   VC 16.96333 0.6342703     16.96333 13.099671
```

```r
lapply(s2, with, data.frame(supp = unique(supp),
                            mlen = mean(len),
                            mySummary(data.frame(len = len, dose = dose)))) |>
    do.call(what = rbind)
```

```
     supp     mlen len dose
OJ.7   OJ 20.66333 8.2  0.5
OJ.8   OJ 20.66333 9.4  0.5
OJ.4   OJ 20.66333 9.7  0.5
VC.1   VC 16.96333 4.2  0.5
VC.9   VC 16.96333 5.2  0.5
VC.4   VC 16.96333 5.8  0.5
```



# aggregate

- Several scalar-valued functions

Can only do one at a time (and merge 2 at a time). Not ideal.


```r
merge(aggregate(len ~ supp + dose, ToothGrowth, mean),
      aggregate(len ~ supp + dose, ToothGrowth, sd),
      by = c("supp", "dose"))
```

```
  supp dose len.x    len.y
1   OJ  0.5 13.23 4.459709
2   OJ  1.0 22.70 3.910953
3   OJ  2.0 26.06 2.655058
4   VC  0.5  7.98 2.746634
5   VC  1.0 16.77 2.515309
6   VC  2.0 26.14 4.797731
```

```r
## can't name unless more than one result
aggregate(len ~ supp + dose, ToothGrowth,
          function(x) c(m = mean(x), foo = 1))
```

```
  supp dose len.m len.foo
1   OJ  0.5 13.23    1.00
2   VC  0.5  7.98    1.00
3   OJ  1.0 22.70    1.00
4   VC  1.0 16.77    1.00
5   OJ  2.0 26.06    1.00
6   VC  2.0 26.14    1.00
```


- Scalar valued functions with vector input: not possible using `aggregate()`

- Vector valued functions with scalar / vector input

Scalar input OK, vector not possible.


```r
aggregate(len ~ supp, ToothGrowth,
          function(x) c(m = mean(x), s = sd(x)))
```

```
  supp     len.m     len.s
1   OJ 20.663333  6.605561
2   VC 16.963333  8.266029
```

On the other hand, can do nice things for scalar input like


```r
aggregate(len ~ supp + dose, ToothGrowth, quantile)
```

```
  supp dose len.0% len.25% len.50% len.75% len.100%
1   OJ  0.5  8.200   9.700  12.250  16.175   21.500
2   VC  0.5  4.200   5.950   7.150  10.900   11.500
3   OJ  1.0 14.500  20.300  23.450  25.650   27.300
4   VC  1.0 13.600  15.275  16.500  17.300   22.500
5   OJ  2.0 22.400  24.575  25.950  27.075   30.900
6   VC  2.0 18.500  23.375  25.950  28.800   33.900
```

One limitation is that `aggregate()` doesn't seem to be able to handle
non-atomic vector output; e.g.,


```r
aggregate(len ~ supp, ToothGrowth,
          function(x) data.frame(m = mean(x), s = sd(x)))
```

```
Warning in format.data.frame(if (omit) x[seq_len(n0), , drop = FALSE] else x, : corrupt data frame:
columns will be truncated or padded with NAs
```

```
  supp      len
1   OJ 20.66333
2   VC 16.96333
```


# tapply

Currently doesn't work for data frame, but with check removed:

```
     nI <- length(INDEX)  # now, 'INDEX' is not classed
     if (!nI) stop("'INDEX' is of length zero")
-    if (!all(lengths(INDEX) == length(X)))
-        stop("arguments must have same length")
     namelist <- lapply(INDEX, levels)#- all of them, yes !
     extent <- lengths(namelist, use.names = FALSE)
     cumextent <- cumprod(extent)
```



```r
tapply(ToothGrowth, with(ToothGrowth, list(supp)),
       function(d) with(d, data.frame(supp = unique(supp),
                                      mlen = mean(len),
                                      as.list(coef(lm(len ~ log(dose)))))))
```

```
$OJ
  supp     mlen X.Intercept. log.dose.
1   OJ 20.66333     20.66333  9.254889

$VC
  supp     mlen X.Intercept. log.dose.
1   VC 16.96333     16.96333  13.09967
```

```r
s <- 
tapply(ToothGrowth, with(ToothGrowth, list(supp, dose)),
       function(d) with(d, data.frame(supp = unique(supp),
                                      dose = unique(dose),
                                      mlen = mean(len),
                                      mdose = mean(log(dose)))))

do.call(rbind, s)
```

```
  supp dose  mlen      mdose
1   OJ  0.5 13.23 -0.6931472
2   VC  0.5  7.98 -0.6931472
3   OJ  1.0 22.70  0.0000000
4   VC  1.0 16.77  0.0000000
5   OJ  2.0 26.06  0.6931472
6   VC  2.0 26.14  0.6931472
```

We could actually avoid the function definition and use NSE instead if we use `FUN = with`.


```r
s <- 
    tapply(ToothGrowth, with(ToothGrowth, list(supp, dose)),
           with, data.frame(supp = unique(supp),
                            dose = unique(dose),
                            mlen = mean(len),
                            mdose = mean(log(dose))))
do.call(rbind, s)
```

```
  supp dose  mlen      mdose
1   OJ  0.5 13.23 -0.6931472
2   VC  0.5  7.98 -0.6931472
3   OJ  1.0 22.70  0.0000000
4   VC  1.0 16.77  0.0000000
5   OJ  2.0 26.06  0.6931472
6   VC  2.0 26.14  0.6931472
```

This also works with multi-row functions.


```r
tapply(ToothGrowth, ToothGrowth$supp,
       with, data.frame(supp = unique(supp),
                        mySummary(data.frame(len = len, dose = dose)))) |>
    do.call(what = rbind)
```

```
     supp len dose
OJ.7   OJ 8.2  0.5
OJ.8   OJ 9.4  0.5
OJ.4   OJ 9.7  0.5
VC.1   VC 4.2  0.5
VC.9   VC 5.2  0.5
VC.4   VC 5.8  0.5
```


This is already quite nice, except that we need to include the unique
values of the splitting factors in the summary function.


# Possible extensions

## `aggregate`

We could extend `aggregate` so that

```r
aggregate( ~ supp + dose, ToothGrowth, FUN)
```

applies `FUN` on the components of `split(ToothGrowth, ~ supp +
dose)`. This is currently an error, so should be OK.

But I am not sure when and how to allow arbitrary functions that
operate on the sub-dataframes.


## `tapply`

`tapply` has more immediate promise. We can support formulas fairly
easily, similar to split:

```
tapply <- function (X, INDEX, FUN = NULL, ..., default = NA, simplify = TRUE)
 {
     FUN <- if (!is.null(FUN)) match.fun(FUN)
+    if (inherits(INDEX, "formula")) INDEX <- formula2varlist(INDEX, X)
     if (!is.list(INDEX)) INDEX <- list(INDEX)
```

with a new `formula2varlist()`, a version of which is already used in
`split()` without the checks:

```r
formula2varlist <- function(formula, data, warnLHS = TRUE, ignoreLHS = warnLHS)
{
    if (!inherits(formula, "formula")) stop("'formula' must be a formula")
    if (length(formula) == 3) {
        if (warnLHS) {
            if (ignoreLHS)
                warning("Unexpected LHS in 'formula' has been ignored.")
            else
                warning("Unexpected LHS in 'formula' has been combined with RHS.")
        }
        if (ignoreLHS) formula <- formula[-2]
    }
    fterms <- stats::terms(formula)
    ans <- eval(attr(fterms, "variables"), data, environment(formula))
    names(ans) <- attr(fterms, "term.labels")
    ans
}
```

With this, we have


```r
tapply(ToothGrowth, ~ supp + dose, with, mean(len))
```

```
    dose
supp   0.5     1     2
  OJ 13.23 22.70 26.06
  VC  7.98 16.77 26.14
```

```r
tt <- tapply(ToothGrowth, ~ supp + dose,
             with, data.frame(m = mean(len), s = sd(len)),
             simplify = FALSE)
tt
```

```
    dose
supp 0.5          1            2           
  OJ data.frame,2 data.frame,2 data.frame,2
  VC data.frame,2 data.frame,2 data.frame,2
```

```r
tt[2,2][[1]]
```

```
      m        s
1 16.77 2.515309
```

```r
do.call(rbind, tt)
```

```
      m        s
1 13.23 4.459709
2  7.98 2.746634
3 22.70 3.910953
4 16.77 2.515309
5 26.06 2.655058
6 26.14 4.797731
```

All we need now is a enhanced version of rbind which adds the margins
as columns, as `as.data.frame.table()` does.

## Reversing `tapply()`

We basically want something that reverses `tapply()`. For scalar
output and a single factor, `lattice::make.groups()` works.


```r
tapply(ToothGrowth, ~ supp, with, mean(len), simplify = FALSE) |>
    do.call(what = lattice::make.groups)
```

```
       data which
OJ 20.66333    OJ
VC 16.96333    VC
```

Should we think of something like that but more general?

