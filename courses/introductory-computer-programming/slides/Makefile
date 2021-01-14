
all: 01-orientation.html 02-introduction-1.html 02-introduction-2.html \
     03-roverview-1.html 03-roverview-1.R 03-roverview-2.html       \
     04-rbasics-1.html 04-rbasics-2.html 05-rbasics-3.html 06-rbasics-4.html \
     07-nseval-1.html 07-nseval-2.md

%.md: %.rmd
	Rscript -e "library(knitr); knit('$<')"

%.R: %.rmd
	Rscript -e "library(knitr); purl('$<', documentation = 0)"

%.html: %.md
	cp '$<' '$@' 

