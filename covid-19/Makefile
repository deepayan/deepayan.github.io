
all: doubling.html

.PRECIOUS: %.md


# See reveal.js/plugin/math/math.js if facing mathjax problems

%.md: %.rmd
	Rscript -e "library(knitr); knit('$<')"

%.html: %.md bsheader.html.in bsbefore.html.in bsbefore.html.in
	pandoc -s -t html --mathjax -H bsheader.html.in	 	\
	-B bsbefore.html.in -A bsbefore.html.in -o '$@' '$<'


web: all
	rsync -av --delete ./ www.isid.ac.in:public_html/COVID-19/



