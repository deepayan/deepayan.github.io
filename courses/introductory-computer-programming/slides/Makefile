
all: 01-orientation.html 02-introduction-1.html 02-introduction-2.html 03-roverview-1.html 03-roverview-1.R

.PRECIOUS: %.md

%.md: %.rmd
	Rscript -e "library(knitr); knit('$<')"

%.R: %.rmd
	Rscript -e "library(knitr); purl('$<', documentation = 0)"

%.html: %.md
	cp '$<' '$@' 

