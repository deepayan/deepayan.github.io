---
title: RFC - Extending the R Graphics Engine to Support Interaction
author: Deepayan Sarkar, Michael Lawrence, Paul Murrell
---




# Introduction

The standard R screen / file devices have very limited possibilities
when it comes to interaction (most generally through
`getGraphicsEvent()`), and what little there is blocks other
operations. There is not much scope for enhancement given the need to
support legacy devices; however, at least two types of passive
interaction can be easily added in principle as _optional_ features
that a device can choose to support:

- Tooltips

- Links

This RFC is for a proposal to add API points to the R Graphics engine
to support these features, and possibly others that we have not
thought of.

As a proof of concept, we can look at the (now archived)
[`RSVGTipsDevice`](https://cran.r-project.org/src/contrib/Archive/RSVGTipsDevice/)
package which implements these features bypassing the graphics
device. Having support in the graphics engine will substantially
simplify the user API. Once the engine support is available, it should
be fairly easy to implement them at least in the
[`svglite`](https://cran.r-project.org/package=svglite) package (for
plots that can then be included in HTML documents) and possibly
[`httpgd`](https://cran.r-project.org/package=httpgd) (for a
cross-platform interactive screen device).


# Proposed extensions to the graphics engine

The proposal is to extend the graphics engine API to allow interactive
elements to be specified. So far, we are only thinking of tooltips and
links, but there may be others we haven't thought of.

Specifically, we propose new API entry points

- `dev->beginTooltip(const char *tooltip)`

- `dev->endTooltip()`

- `dev->beginHyperlink(const char *href)`

- `dev->endHyperlink()`

In principle, any graphical elements drawn between a
`dev->beginTooltip()` and a `dev->endTooltip()` should get an
associated tooltip, and similarly for hyperlinks.

For example, a user-level call might end up looking like

```r
points(x = 1:12, y = 1:12, pch = 1, tooltip = month.name)
```

which would end up calling 

```c
for (i = 0; i < 12; i++) {
    dev->beginTooltip(month.name[i]);
	dev->circle(x[i], y[i]);
	dev->endTooltip();
}
```

It would be up to the device to store the "current" tooltip or href
info and make use of it in whatever gets drawn while it is
active. Devices that are not going to support these features can
simply ignore these new calls by implementing them as no-ops.


# R level API

There is a lot more flexibility in the R level API, so we don't need
to pin down details right now. It should not be too much of a problem
to add new arguments to `points()`, `grid.points()`, etc.

# Questions

Before we move forward with an implementation, it would be useful to
have a discussion on what the final API should look like. Specifically,

- Are there any potential downsides to this approach? From our initial
  discussions, this should be sufficiently orthogonal to the existing
  API to keep any disruption minimal.

- Are there any other kinds of interaction it might be possible to
  support? Note that it's probably not realistic to have features that
  require calling back into R in response to an interaction event.



