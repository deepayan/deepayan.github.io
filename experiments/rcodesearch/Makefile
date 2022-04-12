
all: taginfo.json


TAGS:
	./generate-etags.sh


taginfo.json: TAGS
	R --vanilla < etags2html.R


