---
layout: default
title: 'Predicting COVID-19 cases'
author: Deepayan Sarkar
---








[This note was last updated using data downloaded on 
2020-07-20. Here is the
[source](https://github.com/deepayan/deepayan.github.io/blob/master/covid-19/prediction.rmd) of this analysis. Click <a href="#"
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


















