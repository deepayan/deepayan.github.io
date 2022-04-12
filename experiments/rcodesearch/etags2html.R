

## Read etags file and generate a CSV file


etags2table <-
    function(infile, outfile,
             src_prefix = "src")
{
    SEP <- "\t"
    prefix_skip <- nchar(src_prefix) + 1L
    tagfile.lines <- readLines(infile)
    srcfile.locs <- which(startsWith(tagfile.lines, src_prefix))
    if (!length(srcfile.locs)) stop("No matches found; check src_prefix")
    if (file.exists(outfile)) unlink(outfile)
    fwrite  <- function(a,b,c) cat(a, SEP, b, SEP, c, "\n",
                                   file = outfile, append = TRUE, sep = "")
    for (i in srcfile.locs)
    {
        info <- strsplit(tagfile.lines[[i]], ",", fixed = TRUE)[[1]]
        ## info[[1]] is file name, info[[2]] is size in bytes of
        ## corresponding tag information. We should read next lines
        ## one by one until we reach info[[2]] bytes
        tagsize <- as.integer(info[[2]])
        if (tagsize > 0)
        {
            j <- i + 1L
            cumsize <- 0
            while (cumsize < tagsize)
            {
                tagline <- tagfile.lines[[j]]
                cumsize <- cumsize + nchar(tagfile.lines[j], type = "bytes") + 1L
                tagline2 <- strsplit(tagline, "\x7f", fixed = TRUE)[[1]][[2]]
                taginfo <- strsplit(tagline2, "\x01", fixed = TRUE)[[1]]
                if (length(taginfo) == 1) {
                    ## for etags-produced tags for C, it seems there
                    ## is no "\x01".  then first part of the tag line
                    ## (which we otherwise ignore) is like 'double
                    ## pgeom(' or '#define xbig '. So just remove last
                    ## character, then split on space, and take last
                    ## part
                    tagline1 <- strsplit(tagline, "\x7f", fixed = TRUE)[[1]][[1]]
                    token <- substring(tagline1, 1, nchar(tagline1) - 1L)
                    token <- tail(strsplit(token, "[[:space:]+]")[[1]], 1)
                    fwrite(substring(info[[1]], prefix_skip), # file name
                           token, # token
                           taginfo[[1]]) # start line + something irrelevant
                }
                else if (length(taginfo) == 2) {
                    fwrite(substring(info[[1]], prefix_skip), # file name
                           taginfo[[1]], # token
                           taginfo[[2]]) # start line + something irrelevant
                }
                else stop("unexpected tag line: ", tagfile.lines[[j]])
                j <- j + 1L
            }
        }
    }
    invisible()
}



table2json <- 
    function(infile, outfile = "",
             dest_prefix = "https://github.com/wch/r-source/blob/trunk/src",
             limit = 500)
{
    require(jsonlite)
    tag_data <- read.table(infile, header = FALSE,
                           quote = "", sep = "\t", comment.char = "")
    colnames(tag_data) <- c("srcfile", "token", "startline")
    tag_data <- within(tag_data,
    {
        startline <- sapply(strsplit(startline, ",", fixed = TRUE), "[[", 1L)
    })
    if (limit > 0) tag_data <- head(tag_data, limit)
    ## str(tag_data)
    HREF <- with(tag_data,
                 sprintf("<a href='%s%s#L%s' target='_blank'>%s</a>",
                         dest_prefix, srcfile, startline, srcfile))
    ans <- list(data = vector(mode = "list", length = nrow(tag_data)))
    for (i in seq_len(nrow(tag_data)))
    {
        ans$data[[i]] <- with(tag_data, list(token[i], HREF[i], startline[i]))
    }
    write_json(ans, outfile)
}
    

## We don't actually use this any more; instead create a JSON file
## using table2json() and load it via ajax for (substantially) better
## load time. The HTML can remain unchanged. Retained for reference.

table2html <- 
    function(infile, outfile = "",
             dest_prefix = "https://github.com/wch/r-source/blob/trunk/src",
             limit = 500)
{
    tag_data <- read.table(infile, header = FALSE,
                           quote = "", sep = "\t", comment.char = "")
    colnames(tag_data) <- c("srcfile", "token", "startline")
    tag_data <- within(tag_data,
    {
        startline <- sapply(strsplit(startline, ",", fixed = TRUE), "[[", 1L)
    })
    if (limit > 0) tag_data <- head(tag_data, limit)
    ## str(tag_data)
    HREF <- with(tag_data,
                 sprintf("<a href='%s%s#L%s' target='_srccode'>%s</a>",
                         dest_prefix, srcfile, startline, token))
    append <- if (outfile == "") FALSE else { unlink(outfile); TRUE }
    fwrite  <- function(...) cat(..., "\n", file = outfile, append = append, sep = "\n")
    
    fwrite("<!DOCTYPE html>",
           "<html>",
           "<head>",
           "<meta charset='utf-8' />",
           "<title>R Code Search</title>",
           "<meta name='viewport' content='width=device-width, initial-scale=1.0, user-scalable=yes' />",
           "<link rel='stylesheet' href='https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css' integrity='sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh' crossorigin='anonymous'>",
           "<link rel='stylesheet' href='https://cdn.datatables.net/1.11.3/css/dataTables.bootstrap4.min.css'>",
           "<style type='text/css'>",
           "  body { padding-top: 10px; }",
           "  #ftable { font-family: monospace; }",
           "  #isrc { width: 100%; height: 90%; }",
           "</style>",
           "</head>",
           "<body>",
           "<div class='container'>",
           "<h1>R Code Search</h1>")
    fwrite("<table class='table table-striped table-bordered' id='ftable'>")
    ## table header
    fwrite("<thead>", "<tr>",
           "    <th>Function</th><th>Source</th><th>Line</th>",
           "</tr>", "</thead>")

    fwrite(
        with(tag_data,
             sprintf("<tr><td>%s</td><td>%s</td><td>%s</td></tr>",
                     HREF, srcfile, startline))
    )
    
    fwrite("</table>")

    fwrite("<iframe src='' id='isrc' name='_srccode' title='Source code'></iframe>")
    
    fwrite("</div>")

    fwrite("

<script src='https://code.jquery.com/jquery-3.4.1.min.js'
        integrity='sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo='
        crossorigin='anonymous'>
</script>

<script src='https://cdn.datatables.net/1.11.3/js/jquery.dataTables.min.js'
        crossorigin='anonymous'>
</script>

<script src='https://cdn.datatables.net/1.11.3/js/dataTables.bootstrap4.min.js'
        crossorigin='anonymous'>
</script>

<script src='https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js'
        integrity='sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6'
        crossorigin='anonymous'>
</script>

<script type='text/javascript'>

$(document).ready(function() {
    $('#ftable').DataTable({
        'paging': true,
    });
} );

</script>
")
    fwrite("</body>",
           "</html>")
    invisible()
}


etags2json <-
    function(infile, outfile,
             src_prefix = "/Users/deepayan/svn/all/r-project/R/trunk/src",
             dest_prefix = "https://github.com/wch/r-source/blob/trunk/src",
             limit = 1000)
{
    tsvfile <- "taginfo.csv" # tempfile("taginfo", fileext = ".tsv")
    on.exit(unlink(tsvfile))
    etags2table(infile, tsvfile, src_prefix = src_prefix)
    cat("Done: ", infile, " -> ", tsvfile, "\n")
    table2json(tsvfile, outfile = "taginfo.json", limit = 0)
    cat("Done: ", tsvfile, " -> taginfo.json\n")
    ## table2html(tsvfile, outfile = "rcodesearch.html",
    ##            dest_prefix = dest_prefix,
    ##            limit = limit)
    ## cat("Done: taginfo.json -> ", oufile, "\n")
    invisible()
}

etags2json("TAGS", limit = 0)

## table2json("taginfo.csv", outfile = "taginfo.json", limit = 0)

