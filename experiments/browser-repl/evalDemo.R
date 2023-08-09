
## adapted from demo("echo", package = "httpuv")

## use this by running source('evalDemo.R') in R

library(httpuv)


## quit <- function(status = 0) invokeRestart("done", status)


escapeMarkup <- function(s)
{
    ## escape < > &
    s <- gsub("&", "&amp;", s, fixed = TRUE)
    s <- gsub("<", "&lt;", s, fixed = TRUE)
    s <- gsub(">", "&gt;", s, fixed = TRUE)
    s
}


## Determine whether a string contains a complete expression or set of
## expressions separated by semicolons.
inputComplete <- function(text) {
    tryCatch({ parse(text = text, srcfile = FALSE); return('') },
             error = function(e) {
                 m <- paste(conditionMessage(e), collapse = "\n")
                 m
             })
}


make_repl_helpers <- function()
{
    ## These are global variables used by the following functions to
    ## manage the handling or warnings.
    warningCount <- 0
    warn <- getOption("warn")

    ## FIXME: the hard-coded limit of 50 should be taken from options()

    ## set $call component to NULL for top-level conditions
    modifyToplevel <- function(cond, verbose = TRUE) {
        if (verbose) {
            message("condition")
            capture.output(str(cond), file = stderr())
        }
        ccall <- conditionCall(cond)
        if (!is.null(ccall) && ccall == quote(eval(expr, .GlobalEnv, baseenv())))
            cond$call <- NULL # toplevel error / warning
        cond
    }

    warningList <- list() # can't use last.warning, so...
    warning2error <- NULL # to handle warn=2

    ## FIXME: Not done yet, but it should be possible to handle
    ## message()-s similarly
    
    warningHandler <- function(w) {
        w <- modifyToplevel(w)
        if (warn < 0)
            invokeRestart("muffleWarning")
        else if (warn == 0) {
            new <- list(conditionCall(w))
            names(new)[[1]] <- conditionMessage(w)
            if (warningCount < 50) {
                if (warningCount > 0)
                    new <- c(warningList, new)
                warningList <<- new
                warningCount <<- warningCount + 1
            }
            invokeRestart("muffleWarning") ## to skip internal handling
        }
        else if (warn == 1) {
            ## print warnings 'immediately' - how?
            ## **** need to truncate if long
            wout <- capture.output(
            {
                if (is.null(conditionCall(w))) ## for toplevel calls
                    cat("Warning:", conditionMessage(w), "\n")
                else
                    cat("Warning in", deparse(conditionCall(w)), ":",
                        conditionMessage(w), "\n")
            })
            cat(htmlWARNING(wout))
            invokeRestart("muffleWarning")
        }
        else {
            ## We need to mimic an error without really stop()-ing,
            ## [unless we do the REPL through a proper restart mechanism
            ## stop(w) ?]
            warning2error <<- 
                simpleError(message = paste("(converted from warning)", conditionMessage(w)),
                            call = conditionCall(w))
            invokeRestart("muffleWarning")
        }
    }

    ## ## TODO
    ## htmlOUTPUT <- function(s) {
    ##     somthing that handles terminal escape codes?
    ## }
    
    htmlWARNING <- function(s)
        if (length(s))
            sprintf("<em class='warn'>%s</em>", paste(escapeMarkup(s), collapse = "\n"))
        else s

    htmlERROR <- function(s)
        if (length(s))
            sprintf("<strong class='error'>%s</strong>", paste(escapeMarkup(s), collapse = "\n"))
    else s

    ## TODO: think about whether it may be better to have something that returns a list of
    ## list(value = result,
    ##      visible = logical(1),
    ##      output = character(),    # str(), cat(), etc
    ##      messages = character(),  # message()
    ##      warnings = character(),  # warning()
    ##      errors = character())    # stop()
    captureEvalWithVisibility1 <- function(expr) {
        output <- capture.output(
        {
            ### see https://github.com/r-lib/evaluate/issues/12
            result <- try(
                withVisible(eval(expr, .GlobalEnv, baseenv())),
                silent = TRUE
            )
        })
        if (inherits(result, "try-error")) {
            e <- attr(result, "condition")
            result <- list(error = modifyToplevel(e))
        }
        result$output <- output
        result
    }

    captureEvalWithVisibility2 <- function(expr) {
        withCallingHandlers(captureEvalWithVisibility1(expr),
                            warning = warningHandler)
    }
    
    captureWarnings <- function() {
        if (warningCount > 0) {
            if (warningCount <= 10)
                ## **** it would be better to be able to print
                ## **** directly to stdout without using sink()
                ## **** (which is what capture.output does).
                capture.output(print(
                    structure(warningList, class = "warnings")
                ))
            else if (warningCount < 50)
                c("There were", as.character(warningCount), "warnings",
                  "(use warnings() to see them)\n")
            else
                c("There were 50 or more warnings",
                  "(use warnings() to see the first 50)\n")
        }
        else NULL
    }

    do_eval_capture <- function(exprList) {
        warningCount <<- 0

        output <- htmlWARNING(captureWarnings())
        for (expr in exprList) {
            warn <<- getOption("warn")
            warning2error <<- NULL # for warn=2
            warningCount <<- 0
            result <- captureEvalWithVisibility2(expr)
            output <- append(output, result$output)
            if (!is.null(result$error))
            {
                output <- append(output, htmlERROR(as.character(result$error)))
                break # skip remaining expressions
            }
            else if (!is.null(warning2error)) {
                ## error due to warn=2, but not handled in eval() - mechanism not clear to me
                output <- append(output, htmlERROR(as.character(warning2error)))
                break # skip remaining expressions
            }
            else {
                ## message("no error, proceeding to print: ", result$visible)
                ## str(result)

                ## FIXME: Errors / warnings during print() will not be
                ## handled. Maybe move this within
                ## captureEvalWithVisibility2() too? Or better to do
                ## via conditions and handlers?
                if (result$visible)
                    output <- append(output,
                                     escapeMarkup(capture.output(print(result$value))))
            }
            output <- append(output, htmlWARNING(captureWarnings()))
        }
        ## print(output)
        output
    }

    environment()
}


repl_helpers <- make_repl_helpers()

app <- list(
  call = function(req) {
      TEMPLATE_URL <- "https://deepayan.github.io/experiments/browser-repl/template.html"
      template <- paste(readLines(TEMPLATE_URL), collapse = "\r\n")
      wsUrl = paste(sep='',
                    '"',
                    "ws://",
                    ifelse(is.null(req$HTTP_HOST), req$SERVER_NAME, req$HTTP_HOST),
                    '"')
      list(status = 200L,
           headers = list('Content-Type' = 'text/html'),
           body = sprintf(template, wsUrl))
  },
  ## staticPaths = list("/assets" = staticPath("assets", indexhtml = FALSE)),
  onWSOpen = function(ws) {
      ws$onMessage(function(binary, message) {
          ## str(message)
          print(ok <- (inputComplete(message) == ''))
          if (ok) {
              exprList <- parse(text = message, srcfile = NULL)
              output <- repl_helpers $ do_eval_capture(exprList)
              ws$send(paste(output, collapse = "\n"))
          }
          else # not ok - can we send an error code somehow? see docs
              ws$send("~~INCOMPLETE~~")
      })
  }
)

options(help_type = "html")
help.start()

## s <- runServer("0.0.0.0", 9454, app)
s <- startServer("0.0.0.0", 9454, app, FALSE)

browseURL("http://localhost:9454/")


## while(TRUE) service(0)


### Test cases
### - sqrt(-10)

## Ideas to try:

## - Separate web-sockets (with different port numbers) for completion
## - (triggered by TAB) and evaluation (triggered by Enter or
## - Ctrl+Enter). One of them must have a $call() component to
## - generate the initial page, but hopefully for the others this can
## - be a no-op

## - Maybe one more just to decide if expression can be parsed, and if
## - not, show error message in a message box

## - Separate 'column' (potentially with multiple tabbed sub-pages,
## - but primarily) with a textarea where all evaluated statements are
## - appended (this serves the purpose of history). It should be also
## - possible to edit this manually and evaluate sections. This would
## - be an alternative to the REPL.

## Script editor desirable features:

## - Maybe just use an established code editor. See README.md

## - [Eventually] Load/save from/to files (which could be done through R via
## - websockets - maybe keep another server for that).

## - Select + Ctrl-Enter evaluates selected code. If no selection,
## - Ctrl-Enter selects from <start of current line> to <first
## - complete set of lines>



