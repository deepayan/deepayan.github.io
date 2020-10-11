
all: opencv-intro.html

.PRECIOUS: %.md

# See reveal.js/plugin/math/math.js if facing mathjax problems

%.md: %.rmd
	Rscript -e "library(knitr); knit('$<')"

%.html: %.md ../assets/snippets/bsheader.html.in ../assets/snippets/bsbefore.html.in ../assets/snippets/bsafter.html.in
	pandoc -s --to html --mathjax						\
		--from markdown-markdown_in_html_blocks				\
		-H ../assets/snippets/bsheader.html.in 				\
		-B ../assets/snippets/bsbefore.html.in				\
		-A ../assets/snippets/bsafter.html.in				\
		-o '$@' '$<'


web: all
	rsync -av --delete ./ www.isid.ac.in:public_html/rip/



