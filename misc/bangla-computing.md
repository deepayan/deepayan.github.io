---
title: Bangla computing and I
author: Deepayan Sarkar
---

The years I spent as a graduate student in Madison were some of the
most enjoyable in my life, mainly because I had lots of free time and
very few responsibilities. I ended up spending almost as much time, if
not more, on unofficial hobbies as I did on my Ph.D.  Most of my free
time was probably spent on
[lattice](https://github.com/deepayan/lattice), but I also spent a lot
of time on various initiatives related to technologies enabling the
use of Bengali on computers.  One of the first internet communities I
was part of was an ad hoc group of fellow Bangla computing enthusiasts
under who banded as a collective named _Ankur_ (originally called
_bengalinux_).

# Bengali literature archive

I don't quite remember _exactly_ how I got involved with Ankur, but
the impetus was an idea I had had for a while, which was to create an
_online_ archive of public domain Bengali literature, similar to
[Project Gutenberg](https://www.gutenberg.org/). In theory, this was
just a matter of typing up whatever I had the time and inclination
for, but in practice, there were many technical challenges.

The time was the early 2000s, and the internet had not yet started
using Unicode, although it was clear to those technically inclined
that it was going to be the
future. [ISCII](https://en.wikipedia.org/wiki/Indian_Script_Code_for_Information_Interchange)
had never really caught on. Popular bengali websites, such as
[anandabazar.com](http://web.archive.org/web/20010118221900/https://www.anandabazar.com/),
were using proprietary solutions, often tied to particular browsers
(making snapshots of their websites taken at the time completely
useless now). A company whose name I have forgotten had come out with
CD containing all the works of Rabindranath Tagore, but it also came
with an ad hoc encoding.

I had by that time already been influenced by the ideas of Richard
Stallman, and had no intention of using proprietary technologies. One
reasonable solution was
[Bangtex](http://www.saha.ac.in/theory/palashbaran.pal/bangtex/bangtex.html),
which was a LaTeX extension that could be used to typeset Bengali. It
was open source, but could only produce PDF files, not HTML, and more
importantly, it also used an ad hoc encoding that was specific to the
font being used, making it not a worthwhile investment if one wanted
to be future-proof.

It was quite clear even at the time that Unicode was the "right"
solution in terms of encoding Indic languages. The idea of Unicode
itself was not novel (the Indic language encodings were based on the
earlier ISCII encoding), but now Microsoft was heavily invested in it
(presumably as part of their plans to expand into non-European
territories), which meant that it was very likely to be widely
adopted. What was still missing was a functional implementation of all
the pieces that would make the technology work seamlessly on all
platforms.

The [earliest
version](http://web.archive.org/web/20021208180443/http://www.stat.wisc.edu/~deepayan/Bengali/WebPage/bengali.html)
of my Bengali archive that I could find on the Wayback Machine has a
good summary of the issues, which have all been resolved since then,
with some contributions from the Ankur group along the way. The most
challenging problem was the lack of a useable (let alone good) font.
There was a font called
[Code2000](https://en.wikipedia.org/wiki/Code2000) which covered
almost all Unicode characters including Bengali, but did not have much
in terms of OpenType layout support (for conjucts and other visual
features). Microsoft was distributing a Devanagari font called
[Mangal](https://docs.microsoft.com/en-us/typography/font-list/mangal),
but their eventual Bengali font
[Vrinda](https://docs.microsoft.com/en-us/typography/font-list/vrinda)
was not yet available. So, even though I had no experience with
typography or any other kind of design for that matter, I decided to
try my hand at creating a font myself, which turned out to be not too
difficult. The name of the font was "Likhan"; the font shapes were
created using a nice open source software called Pfaedit (since
renamed as [FontForge](https://fontforge.org/)), with Opentype layout
tables added using Microsoft's [Visual Opentype Layout Tool
(VOLT)](https://docs.microsoft.com/en-us/typography/tools/volt/).

Another practical issue at the time (and even now, to some extent) was
the problem of typing in Bengali. I wrote a couple of web-based tools
to convert phonetic roman input into Unicode Bengali, versions of
which are still available
[here](https://www.isid.ac.in/~deepayan/bninput/). This was my first
non-trivial project with Javascript, so it was fun.

Not many people visited my literature archive, and even fewer people
contributed, so it has basically languished, although I have always
kept some version of it available. Fortunately, the wiki movement has
really taken off since then, and
[wikisource](http://bn.wikisource.org/) has filled the gap that I had
tried to fill, in a much more systematic and collaborative way. I
still try to experiment with my site when I can (especially now that
Google has essentially perfected OCR), and during the COVID-19
lockdown in 2020, I [re-designed](https://majantali.github.io) it as
an exercise to learn about Github Pages.

The font I had designed, and to a lesser extent the Bengali input tool
I had created, turned out to have more substantial, if short-lived,
influence on the wider world. It put me in touch with Ankur, and
sundry people from around the world whom I would not have known
otherwise.


# bengalinux.net

As I said, I don't exactly remember how I got in touch with
bengalinux, but it definitely happened before December 2002. The
`bengalinux-core` mailing list archives start in September 2002;
Likhan is mentioned by [Sayamindu](https://unmad.in/) in October, and
I seem to have become a member by November. I think what happened was
that Sayamindu came across Likhan and asked me to join both the [Free
Bangla Font](http://www.nongnu.org/freebangfont/) project and
bengalinux, and this happened sometime in October.

Fonts were a big focus area in those early days. The rest
(implementation in Free Software systems, or even Windows for that
matter) was not really in our hands and also beyond our skill set,
although we did what we could in terms of testing and reporting bugs,
especially in Pango and Qt, and influencing the development of the
Unicode standards pertaining to Indic languages. Likhan, although not
a good font by any stretch of the imagination, nonetheless became
somewhat popular as our other offerings were equally bad. Eventually,
more professional-looking Bengali Unicode fonts started being
released. I suspect many of them were created by copying the glyphs
from other non-Unicode fonts without permission and pasting them on a
template Unicode font, but the copyright owners did not bother to take
legal action even if they were aware, and as a result the dearth of
Bengali Unicode fonts subsided. My [second
attempt](https://sourceforge.net/p/majantali/code/HEAD/tree/trunk/) at
making Bengali fonts led to a font named Jamrul, which was released
in 2004. It was a much better font than Likhan in my opinion, but
nobody else was interested in it by then. I kept using it myself for
many years, before giving it up in favour of the [Google
Noto](https://www.google.com/get/noto/) fonts.

Ankur, as bengalinux was eventually rebranded as, was home to some
interesting software projects as well (such as an English to Bengali
translator based on a [part-of-speech
tagger](https://en.wikipedia.org/wiki/Part-of-speech_tagging)), but
eventually the focus turned to internationalizaton and localization,
or in other words, translating software interfaces to Bengali. This
was never really a passion of mine. I had little interest in the
outcome unless the results were something I would use, and the initial
focus was on translating the GNOME environment, which made sense
because it was the _de facto_ choice for new users, but it was also
something I rarely used because I had by that time settled on KDE as
my environment of choice (it still is). Secondly, as fun as it was to
see menu items in Bengali, it didn't really help me in any way because
I was perfectly comfortable with the original English.  Without any
additional incentive, it was difficult to sustain interest in
something I would not use myself.

Still, I got into it for a while, translating KDE because that way I
would at least see the results of my work. I did put in a lot of
effort, with help from a few others, but eventually stopped when I
finished my postdoc and moved on to other things. Somewhat sadly, no
one else seems to have has taken up the task of translating KDE to
Bengali in the more than ten years since then.

Eventually, the online community of Ankur fizzled out. Partly this was
because people moved on with their lives, and partly because we had
accomplished what we had started out to do, which was to help enable
Bengali on the web and on Free Software platforms; today, working with
Bengali is as easy on GNU/Linux systems, if not easier, than it is on
Windows or Mac OS. What remained was routine and boring work, perhaps
important, but not as attractive to the hobbyists who started the
group.

My only regret is that I never physically met anyone in the group
other than Sayamindu, and never got to know them closely enough to
know what motivated them to get involved in the first place.





