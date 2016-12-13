# Monads for ~~Functional Programmers~~ IMDEA people
=========================================================================

In this session we want to understand what's the fuss about *monads*. We might not fully understand what they are by the end of the session. But, we should have a practical understanding of what *can be done* using monads.

For that matter, the plan is to read a couple of papers with several examples and ready to run code --- in Haskell, of course--. On the first meeting, we will cover the seminal paper which introduced the use of monads in a _pure_ functional programming language to encapsulate imperative effects. 

The rest of the meetings will cover IMDEA friendly application domains where _monads_ manifest themselves naturally. Or, sort of.

What we will not see, at least in this first session:

1. Monads in/and Category Theory.
1. Computational Lambda Calculus.
2. How to combine monads.
3. Newer approaches to combining effects: free(r) monads, algebraic effects, extensible effects.
4. Indexed Monads and Verification: HTT, F* and other _Klieski arrows of outrageous fortune_.

## Plan

1. Monads for Functional Programmig.
2. Monads for Logic Programming?.
3. A poor man's concurrency monad?.
4. Monad's for security? / Monadic Parsers?.

_NB_ This programme is not fixed, it's a suggestion.

## 1: Monads for Functional Programming

**Paper:** Phil Wadler. _Monads for Functional Programming_. Available [here](http://homepages.inf.ed.ac.uk/wadler/papers/marktoberdorf/baastad.pdf).

**Host:** [@germanD](https://github.com/germanD)

**Date**: Dec 16th, 2016.. 16.30hs. Meeting Room 315.

###Plan

**[TO DO: Complete me!]**

### Resources & Further Reading###

There are lots of monads tutorials, guides and blog-posts around. Most of them are **not** really that useful. I find these, however, worth mentioning:

1. [Monads: Programmer's Definition](https://bartoszmilewski.com/2016/11/21/monads-programmers-definition/) from [Bartoz Milewskis' Programming Caffé](https://bartoszmilewski.com/) has an __imperative-programmer-friendly__ introduction. The [next post in the series](https://bartoszmilewski.com/2016/11/30/monads-and-effects/) is a bit more advanced and, _caveat emptor_, requires speaking some Category Theory lingo. They are both intended as a part for a **CT for programmers** series.
 
2. From the same author, there is also an older series of posts called "Monads for the Curious Programmer": [Part I](https://bartoszmilewski.com/2011/01/09/monads-for-the-curious-programmer-part-1/) and [Part II](https://bartoszmilewski.com/2011/01/09/monads-for-the-curious-programmer-part-2/).

As the paper points out, the credit for discovering how to use monads for giving semantics to impure effectuful computations should go to E. Moggi. His IC91 paper (below) was the inspiration for the whole *monadic* revolution. If you are interesting in dwelving seriously into the subject, it is a good place to start. There might, of course, be dragons.

E.Moggi. [_Notions of Computations and Monads_](http://www.disi.unige.it/person/MoggiE/ftp/ic91.pdf).



## 2: Monads for Logic Programmers?

**Paper:** 
Tom Schrijvers, Peter Stuckey, and Philip Wadler. _Monadic constraint programming_. Available [here](http://homepages.inf.ed.ac.uk/wadler/papers/constraints/constraints.pdf).

## 3: A poor man's concurrency monad

**Paper:** Koen Claesen. _A poor man's concurrency monad_. Available [here]
(http://www.di.ens.fr/~pouzet/cours/systeme/bib/koen-concurrency-poor-man-jpf93.pdf)

## Further ado

If you want to dwell into the more interesting, and modern, research ideas mentioned above: you can continue down the following roads **[TO DO: Complete me!]**

