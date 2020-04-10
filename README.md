
This is a repository for generally useful stuff, such as slides for
various R-related talks, course notes, etc.

Useful resources for making pages using jekyll:

- Jekyll templates: <https://jekyllrb.com/docs/layouts/>

- Github site data: <https://jekyll.github.io/github-metadata/site.github/>

- Google web fonts: <https://www.w3schools.com/howto/howto_google_fonts.asp> / <https://fonts.google.com/>

- Github-flavoured markdown: <https://github.github.com/gfm/> - see about tagfilter


Using math: This is a bit irritating because for some reason,

- Github does not allow disabling of math processing in kramdown (some
  config options are forcefully overridden as explained in
  <https://help.github.com/en/github/working-with-github-pages/about-github-pages-and-jekyll>,
  and `math_engine` is among them)
  
- Kramdown only uses `$$` as math delimiter (both inline and display)

- This is a bit silly to begin with (as the same input would not work
  with LaTeX), and basically just wraps the content around something
  like `<script type="math/tex">`, which works (if `MathJax.js` is
  included) as a side-effect of how MathJax 2 was implemented. This
  doesn't work with MathJax 3, unless the config includes a workaround
  script to explicitly recognize these tags.

- A way to avoid this is to just use `$` for inline and `\[` for
  display mode math, because kramdown leaves them alone even with
  `math_engine: mathjax`, and then MathJax 3 happily renders them
  properly when configured to recognize `$` as a delimiter.
  
- Unfortunately, pandoc doesn't recognize `\[` (and does not have an
  option to leave math code alone (default is to use HTML tags and
  Unicode).
  
In summary, to write markdown that works with both pandoc and
kramdown, the only options seems to be to use `$$`, which is converted
to `script` tags by kramdown, and then have them recognized by MathJax
3 using config settings.

