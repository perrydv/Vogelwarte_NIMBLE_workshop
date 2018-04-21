---
title: "More about the NIMBLE language"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---



In these slides we'll cover the modified subset of R that is supported for compilation.

## What does "modified subset of R" mean?

NIMBLE tries to mimic the arguments and behavior of a selected **subset** of R functions: mostly those needed for basic manipulations and math with numeric, integer, and logical objects.

Sometimes NIMBLE needs slightly different arguments or behavior, so how functions work is **modified**. 

# Finding help for NIMBLE's versions of R functions.

- Often there is a "nim" version of a function.
- Example: `numeric` is automatically converted to `nimNumeric`.
- You can program with `nimNumeric` directly if you prefer.
- Help can be found by `help(nimNumeric)`.

# Basic operations

Functions for creation and manipulation of numeric, integer and logical objects are listed in [Section 10.2.2](../NimbleUserManual.pdf#page=108) of the user manual.

# Example: `numeric`

In R, `numeric` creates a vector of a chosen length, initialized with zeros.

```r
args(numeric)
```

```
## function (length = 0L) 
## NULL
```

```r
numeric(5)
```

```
## [1] 0 0 0 0 0
```

In NIMBLE, we want some finer-grained control:

- initialization from a chosen scalar or vector;
- control over whether initialize values are recycled, or whether 0s are filled in.
- control over whether initialization is done at all.

A goal is to allow efficient C++. It is inefficient to:

- allocate a vector initialized in a way that needs to be over-written.
- initialize unnecessarily.


```r
args(nimNumeric)
```

```
## function (length = 0, value = 0, init = TRUE, fillZeros = TRUE, 
##     recycle = TRUE) 
## NULL
```

```r
nimNumeric(length = 5, value = c(1, 2))
```

```
## [1] 1 2 1 2 1
```

```r
nimNumeric(length = 5, value = c(1, 2), recycle = FALSE, fillZeros = TRUE)
```

```
## [1] 1 2 0 0 0
```

Notice that we can explore this in pure R, as in an uncompiled
nimbleFunction.

In R, we can't avoid initialization of some kind.

```r
nimNumeric(length = 5, init = FALSE) ## still gets zeros in uncompiled mode
```

```
## [1] 0 0 0 0 0
```

Let's look at compiled behavior

```r
numericDemo <- nimbleFunction(
    run = function() {
        ## numeric will be converted to nimNumeric...
        a <- numeric(length = 5, value = c(1, 2))
        print('a\n', a)
        ## ...or you can use write nimNumeric directly
        b <- nimNumeric(length = 5, value = c(1, 2), recycle = FALSE, fillZeros = TRUE)
        print('b\n', b)
        c <- nimNumeric(length = 8, value = c(1, 2), recycle = FALSE, fillZeros = FALSE)
        print('c\n', c)
        d <- nimNumeric(length = 10, init = FALSE)
        print('d\n', d)
        ## If not given, returnType defaults to void(), which is NULL in R.
    }
)
numericDemo()
```

```
## a
## 1 2 1 2 1
## b
## 1 2 0 0 0
## c
## 1 2 0 0 0 0 0 0
## d
## 0 0 0 0 0 0 0 0 0 0
```

```r
CnumericDemo <- compileNimble(numericDemo)
```

```
## compiling... this may take a minute. Use 'showCompilerOutput = TRUE' to see C++ compiler details.
```

```
## compilation finished.
```

```r
CnumericDemo()
```

```
## a
## 1
## 2
## 1
## 2
## 1
## b
## 1
## 2
## 0
## 0
## 0
## c
##            1
##            2
## 1.97626e-323
##            0
##            0
##            0
##            0
## 5.56268e-309
## d
## -1.28823e-231
## -1.49457e-154
##  1.48331e+151
##   7.08923e-71
##   7.11583e-71
##   7.06077e-71
##  3.19228e-110
##  2.11311e+214
##  4.71456e+257
##  6.95875e-309
```

```
## NULL
```

# `matrix` and `array`

In addition to control over initialization, these require a
compile-time argument for the scalar type ('double','integer', or
'logical').


```r
args(nimMatrix)
```

```
## function (value = 0, nrow = NA, ncol = NA, init = TRUE, fillZeros = TRUE, 
##     recycle = TRUE, type = "double") 
## NULL
```

```r
args(nimArray)
```

```
## function (value = 0, dim = c(1, 1), init = TRUE, fillZeros = TRUE, 
##     recycle = TRUE, nDim, type = "double") 
## NULL
```

# Math,  linear algebra, and distributions

Supported math, including linear algebra and distribution functions,
are listed in
[Sections 10.2.3-10.2.4](../NimbleUserManual.pdf#page=109) of the user
manual.

To a large extent, these work as you would expect.

## Type trickiness.

NIMBLE's static typing requires care.  Here is an example:


```r
## function to do A %*% x, with A a matrix and x a vector
matrixMult <- nimbleFunction(
    run = function(A = double(2), x = double(1)) {
        y <- A %*% x
        return(y)
        returnType(double(1))
    }
)
A <- matrix(1:4, nrow = 2)
x <- c(10, 20)
A %*% x
```

```
##      [,1]
## [1,]   70
## [2,]  100
```

```r
matrixMult(A, x)
```

```
##      [,1]
## [1,]   70
## [2,]  100
```

So far, so good.  Now let's compile it:

```r
CmatrixMult <- try(compileNimble(matrixMult))
```

```
## compiling... this may take a minute. Use 'showCompilerOutput = TRUE' to see C++ compiler details.
```

```r
CmatrixMult
```

```
## [1] "Error : Number of dimensions 2 of the return() argument does not match number 1 given in the returnType() statement.\n This occurred for: return(y)\n This was part of the call:  {\n  y <- ARG1_A_ %*% asCol(ARG2_x_)\n  return(y)\n}\n"
## attr(,"class")
## [1] "try-error"
## attr(,"condition")
## <simpleError: Number of dimensions 2 of the return() argument does not match number 1 given in the returnType() statement.
##  This occurred for: return(y)
##  This was part of the call:  {
##   y <- ARG1_A_ %*% asCol(ARG2_x_)
##   return(y)
## }>
```

### What is the problem?

- Like R, NIMBLE defines any result from `%*%` to be a matrix.
- We intuitively know it has only one column, so we feel it is like a
vector.
- We accidentally declared the return type to be a vector.

### Solutions:

1. We could say `returnType(double(2))`

2. If we really want a vector, use `y <- (A %*% x)[,1]`

### It gets harder

These kinds of type errors can be more confusing when they are not
easy for the NIMBLE compiler to catch and explain.


```r
matrixMult2 <- nimbleFunction(
    run = function(A = double(2), x = double(1)) {
        ## Say for some reason we already have used y as a vector
        y <- rnorm(10, mean = 0, sd = 1)
        ## Now we try to use y again
        y <- A %*% x
        return(y)
        returnType(double(1))
    }
)
matrixMult2(A, x)
```

```
##      [,1]
## [1,]   70
## [2,]  100
```

```r
CmatrixMult2 <- try(compileNimble(matrixMult2))
```

```
## compiling... this may take a minute. Use 'showCompilerOutput = TRUE' to see C++ compiler details.
```

```r
CmatrixMult2
```

```
## [1] "Error : Warning, mismatched dimensions in assignment: y <- ARG1_A_ %*% asCol(ARG2_x_).\n"
## attr(,"class")
## [1] "try-error"
## attr(,"condition")
## <simpleError: Warning, mismatched dimensions in assignment: y <- ARG1_A_ %*% asCol(ARG2_x_).>
```

The NIMBLE compiler has caught the error, but it is more confusing.

Since `y` was used as a vector first, it cannot be used as a matrix
(static typing).

# Flow control

NIMBLE supports:

- `if-then-else`
- `for` loops with sequential integer indexing
- `do-while`
- `stop`
- `checkInterrupt` (stop if the user has pressed Ctrl-C)

# Other functions

- `print` and `cat`
- `optim`

# Calling external compiled code

`nimbleExternalCall` will create a `nimbleFunction` that calls some
compiled function (e.g. C or Fortran) for which you provide header
information (argument and return types).

`nimbleRcall` will arrange to call an R function from a compiled
nimbleFunction.  This can be very useful for debugging.

Example:

# `nimbleList` #

