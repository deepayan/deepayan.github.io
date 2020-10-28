
all: doubling.html deaths.html us-states.html prediction.html pooled-testing.html

.PRECIOUS: %.md


# See reveal.js/plugin/math/math.js if facing mathjax problems

%.md: %.rmd knit-utils.R covid-utils.R
	Rscript -e "library(knitr); knit('$<')"

%.html: %.md bsheader.html.in bsbefore.html.in bsafter.html.in
	pandoc -s --to html --mathjax						\
		--from markdown-markdown_in_html_blocks				\
		-H bsheader.html.in -B bsbefore.html.in -A bsafter.html.in	\
		-o '$@' '$<'


web: all
	rsync -av --delete ./ www.isid.ac.in:public_html/COVID-19/



