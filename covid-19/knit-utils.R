


makeHooks <- function()
{
    shared.env <- new.env(parent = emptyenv())
    plot <- function(x, options)
    {
        fnum <- options$fig.num
        fcur <- options$fig.cur
        pages <- options$pages
        label <- options$label
        if ((fnum == 1) || is.null(pages))
        {
            ## simple <img> elements if only one image, or pages == NULL
            ans <- sprintf("<img src='%s'>\n", x)
        }
        else
        {
            id <- label
            html.pagination <- # further args: x, fcur
                sprintf(paste0("<li class='page-item'><a class='page-link' ",
                               "onclick='document.getElementById(\"%s\").src=\"%%s\"' >",
                               "%%d</a></li>\n"), id) 
            html.carousel <- # further args: active, x, fcur
                sprintf(paste0("<div class='carousel-item %%s'>",
                               "<img class='d-block w-100' src='%%s' alt='Slide %%d'></div>\n"))
            ans <- character(0)
            if (isTRUE(pages)) pages <- "pagination"
            switch(pages,
                   pagination =
                       {
                           if (fcur == 1)
                           {
                               ans <- c(ans, "<div class='mx-auto'>\n<nav>\n<ul class='pagination'>\n")
                               shared.env$initial.image <<- x
                           }
                           ans <- c(ans, sprintf(html.pagination, x, fcur))
                           if (fcur == fnum)
                           {
                               ans <- c(ans, "</ul>\n</nav>\n")
                               ans <- c(ans, sprintf("\n<img id='%s' src='%s'>\n</div>\n",
                                                     id, shared.env$initial.image))
                               shared.env$initial.image <<- NULL
                           }
                       },
                   carousel =
                       {
                           if (fcur == 1)
                           {
                               ans <- c(ans, sprintf("<div id='%s' class='carousel slide carousel-fade' data-ride='carousel' data-interval='2000' data-pause='hover'>\n",
                                                     id))
                               ans <- c(ans, "<div class='carousel-inner'>\n")
                           }
                           ans <- c(ans, sprintf(html.carousel,
                                                 if (fcur == 1) "active" else "",
                                                 x, fcur))
                           if (fcur == fnum)
                           {
                               ans <- c(ans, "</div>\n")
                               ans <- c(ans, sprintf("
<a class='carousel-control-prev' href='#%s' role='button' data-slide='prev'>
<span class='carousel-control-prev-icon' aria-hidden='true'>&lt;&lt;</span>
<span class='sr-only'>Previous</span>
</a>
<a class='carousel-control-next' href='#%s' role='button' data-slide='next'>
<span class='carousel-control-next-icon' aria-hidden='true'>&gt;&gt;</span>
<span class='sr-only'>Next</span>
</a>
", id, id))
                               ans <- c(ans, "</div>\n")
                           }
                       })
        }
        ans
    }
    list(plot = plot)
}




hooks <- makeHooks()

knit_hooks$set(plot = hooks$plot)



## <img id="dgt1000" src="figures/doubling-dgt1000-1.png">


