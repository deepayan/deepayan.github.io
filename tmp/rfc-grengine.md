---
title: RFC - Extending the R Graphics Engine to Support Interaction
author: Deepayan Sarkar, Michael Lawrence, Paul Murrell
---




# Introduction

The standard R screen / file devices have very limited possibilities
when it comes to interaction. There is not much scope for enhancement
given the need to support legacy devices; however, at least two types
of interaction can be easily added in principle as _optional_
features that a device can choose to support:

- Tooltips

- Links

This RFC is for a proposal to add API points to the R Graphics engine
to support these features, and possibly others that we have not
thought of.

As a proof of concept, we can look at the
[`RSVGTipsDevice`](https://cran.r-project.org/package=RSVGTipsDevice)
package which implements these features bypassing the graphics
device. Having support in the graphics engine will substantially
simplify the user API. Once the engine support is available, it should
be fairly easy to implement them at least in the
[`svglite`](https://cran.r-project.org/package=svglite) package (for
plots that can then be included in HTML documents) and possibly
[`httpgd`](https://cran.r-project.org/package=httpgd) (for a
cross-platform interactive screen device).


# Proposed extensions to the graphics engine

The proposal is to add new primitives to the graphics engine that
allow interactive elements to be specified. So far, we are only
thinking of tooltips and links, but there may be others we haven't
thought of.

There would be a new primitive corresponding to each existing
primitives that may reasonably support interaction. The primitives
that could most obviously benefit from this are 

- `dev->circle`

- `dev->rect`

- `dev->polygon`

- `dev->text`

We are not sure about `dev->line` and `dev->polyline`, but maybe those
too for completeness.

The proposal is to keep the current primitives as they are, and add
corresponding interactive API points with addtional arguments
`char *hovertext` and `char *linktarget`; e.g.

```
dev_Circle(double x, double y, double r, 
           const pGEcontext gc, pDevDesc dev)
```

would have a corresponding

```
dev_InteractiveCircle(double x, double y, double r,
                      const char *hovertext,
                      const char *linktarget,
                      const pGEcontext gc, pDevDesc dev)
```

and so on. These functions would be responsible for both drawing
objects and enabling interaction, with whatever optimizations they
choose. Existing devices that are not going to implement interactive
features can just call the old functions without the additional
arguments.

# R level API

There is more flexibility in the R level API. It should not be too
much of a problem to add new arguments to `points()`, `grid.points()`,
etc.

# Questions

Before we move forward with an implementation, it would be useful to
have a discussion on what the final API should look like. Specifically,

- Which primitives should have a version that supports interactive
  elements?
  
- Are there any other kinds of interaction it might be possible to
  support?

Note that it's probably not realistic to have features that require
calling back into R in response to an interaction event.



