
all: 01-orientation.html 02-introduction-1.html 02-introduction-2.html \
     03-roverview-1.html 03-roverview-1.R 03-roverview-2.html       \
     04-rbasics-1.html 04-rbasics-2.html 05-rbasics-3.html 06-rbasics-4.html \
     07-nseval-1.html 07-nseval-2.html 08-rapply-1.html 08-rapply-2.html \
     09-rapply-3.html 10-rmisc-1.html 11-insertion-sort-1.html 12-merge-sort-1.html \
     13-randomized-1.html 14-algorithms-misc-1.html

%.md: %.rmd
	Rscript -e "library(knitr); knit('$<')"

%.R: %.rmd
	Rscript -e "library(knitr); purl('$<', documentation = 0)"

%.html: %.md
	cp '$<' '$@' 

