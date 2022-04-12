#!/usr/bin/env sh

RPROG=R

# etags (emacs-style)

${RPROG} CMD rtags --verbose --no-Rd ${HOME}/svn/all/r-project/R/trunk/src

## Format:

##  ("\x0c\n") indicates start of new file
## Next line gives path
## Subsequent lines are of the form
## - "%s\x7f%s\x01%d,%d" lines, tokens, startline, offset
## where 'tokens' is the name of interest and 'startline' gives line number.
## The rest are not of interest. 

## Example:

# 
# /Users/deepayan/git/github/lattice/R/axis.R,612
# ccurrent.panel.limits25,856
# xxscale.components.default97,3750
# yyscale.components.default120,4408
# aaxis.default149,5208
# ccalculateAxisComponents265,9664

