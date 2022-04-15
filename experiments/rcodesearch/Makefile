
all: taginfo.json globals.json


TAGS:
	./generate-etags.sh


taginfo.json: TAGS
	R --vanilla < etags2json.R

globals.json: TAGS
	R --vanilla < etags2json.R


