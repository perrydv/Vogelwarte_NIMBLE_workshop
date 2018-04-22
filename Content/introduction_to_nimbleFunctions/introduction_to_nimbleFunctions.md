---
title: "Introduction to nimbleFunctions"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---




# `nimbleFunction` within R is NIMBLE's programming system #

`nimbleFunction` is like a replacement for `function` (but it is
itself a `function`).

## Two kinds of `nimbleFunction`

1. Simple `nimbleFunction`: a compilable replacement for `function`
with just math and flow control.

2. Two-stage `nimbleFunction`: supports programming with models
   (although a model is not required).

# Simple `nimbleFunction` (no `setup` code):

A simple `nimbleFunction` requires type declarations for inputs and
outputs.

### Example:


```r
timesScalarVector <- nimbleFunction(
    run = function(a = double(0),  #0-dimensional double, aka scalar
                   x = double(1)   #1-dimensional double, aka vector
                   ) {
        ans <- a * x          # regular R math syntax
        return(ans)           # explicit return statement is required
        returnType(double(1)) #vector return type
        # returnType statement can appear anywhere in the function
    })
```

### Uncompiled execution
This can be run uncompiled, with use of R's debugging tools

```r
a <- 2
x <- rnorm(10000)
y <- timesScalarVector(a, x)
head(y)
```

```
## [1] -0.83179881  3.01421313 -0.19144481 -1.20869860 -0.05204928 -0.59229055
```

### Compiled execution
It can also be compiled and run the same way.

```r
CtimesScalarVector <- compileNimble(timesScalarVector)
```

```
## compiling... this may take a minute. Use 'showCompilerOutput = TRUE' to see C++ compiler details.
```

```
## compilation finished.
```

```r
Cy <- CtimesScalarVector(a, x)
head(Cy)
```

```
## [1] -0.83179881  3.01421313 -0.19144481 -1.20869860 -0.05204928 -0.59229055
```

```r
identical(y, Cy)
```

```
## [1] TRUE
```

In this case there is no measurable speed improvement because both
versions run in "0" time because it is so simple.

In other cases:

- Pro: Compiled code is typically faster, sometimes much faster, internally.
- Con: There is some copying overhead for entry and exit to compiled code.

# Two-stage `nimbleFunction`

## Two-stage evaluation

In many programming tasks,

- some steps are needed only once,
- other steps are needed repeatedly.

## MCMC example:

When creating a sampler for a model node `beta` in model `M`:

- Determination of `beta`'s dependencies in `M` is needed only once.
- Running the sampler (with the same dependencies) is needed
repeatedly.

We say an **instance** or **specialization** of the sampler has been
**specialized** to the case of node `beta` in model `M`.

## Toy example for illustration

**Problem:** Say we repeatedly need to multiply elements of one vector, `x`, by
components of the cumulative sum of another vector, `y`.

- `x` will change every time.
- `y` will stay the same.

### Naive solution
We could write this as simple function (or nimbleFunction):


```r
set.seed(1)
multCumsum <- function(x, y) {
    return(x * cumsum(y))
}
x <- seq(.1, 1.0, by = .1)
y <- 1:10
x
```

```
##  [1] 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
```

```r
y
```

```
##  [1]  1  2  3  4  5  6  7  8  9 10
```

```r
cumsum(y)
```

```
##  [1]  1  3  6 10 15 21 28 36 45 55
```

```r
multCumsum(x, y)
```

```
##  [1]  0.1  0.6  1.8  4.0  7.5 12.6 19.6 28.8 40.5 55.0
```

```r
## To use it with a new x, cumsum(y) is wastefully recomputed internally
x2 <- seq(.01, .1, by = .01)
multCumsum(x2, y)
```

```
##  [1] 0.01 0.06 0.18 0.40 0.75 1.26 1.96 2.88 4.05 5.50
```

Efficiency problem:

- We know the same `y` will be used with different `x`s.
- Recomputing `cumsum(y)` every time is wasteful.

### Two-stage solution

**Solution:** Use two-stage evalution to **specialize** a case of
`multCumsum` to `y`.


```r
multCumsumNF <- nimbleFunction(
    setup = function(y) {  ## setup is evaluated in R, never compiled
        CSy <- cumsum(y)   ## Objects created here are available in run code.
    },
    run = function(x = double(1)) { ## This is compilable, so type declarations are needed
        returnType(double(1))
        return(x * CSy)
    }
    ## Additional functions (aka "methods") can be provided
)
```

### Uncompiled execution
Again, this can be used uncompiled (with debugging) or compiled (for speed)

Here is how we'd use it uncompiled:


```r
multCumsumNF_y <- multCumsumNF(y) ## calls setup function
## returns an object with a run method
multCumsumNF_y$run(x)
```

```
##  [1]  0.1  0.6  1.8  4.0  7.5 12.6 19.6 28.8 40.5 55.0
```

```r
## Now we can use it with the new x2 and the old y, which is "baked in"
multCumsumNF_y$run(x2)
```

```
##  [1] 0.01 0.06 0.18 0.40 0.75 1.26 1.96 2.88 4.05 5.50
```

Under the hood, this is an object-oriented (class) system.

We call `multCumsumNF` a **nimbleFunction generator** and
`multCumsum_y` an **instance**,  **specialization**, or **object**.

### Compiled execution

We compile the **instances**:


```r
CmultCumsumNF_y <- compileNimble(multCumsumNF_y)
```

```
## compiling... this may take a minute. Use 'showCompilerOutput = TRUE' to see C++ compiler details.
```

```
## compilation finished.
```

```r
CmultCumsumNF_y$run(x)  ## This calls compiled C++
```

```
##  [1]  0.1  0.6  1.8  4.0  7.5 12.6 19.6 28.8 40.5 55.0
```

```r
CmultCumsumNF_y$run(x2)
```

```
##  [1] 0.01 0.06 0.18 0.40 0.75 1.26 1.96 2.88 4.05 5.50
```

If we need a new instance, we create it in R and compile it indicating
it is in the same NIMBLE project.


```r
y2 <- seq(10, 100, by = 10)
multCumsumNF_y2 <- multCumsumNF(y2)
CmultCumsumNF_y2 <- compileNimble(multCumsumNF_y2, project = multCumsumNF_y)
```

```
## compiling... this may take a minute. Use 'showCompilerOutput = TRUE' to see C++ compiler details.
```

```
## compilation finished.
```

```r
CmultCumsumNF_y2$run(x)
```

```
##  [1]   1   6  18  40  75 126 196 288 405 550
```

```r
CmultCumsumNF_y2$run(x2)
```

```
##  [1]  0.1  0.6  1.8  4.0  7.5 12.6 19.6 28.8 40.5 55.0
```
