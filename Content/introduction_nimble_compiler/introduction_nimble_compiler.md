---
title: "Introduction to the NIMBLE compiler"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---



# Supported R functions and syntax

- Supports much of R's math and distribution functions (details later).
- Supports `for` loops with sequential integer indices.
- Supports `if-then-else` and `do-while`
- Supports object creation with modified versions of `numeric()`, `matrix()` and `array()`
- `nimbleList` supports somewhat list-like data structures
- **Pass-by-reference semantics** in compiled nimbleFunctions.  This
  is fundamentally different (and faster) than R's pass-by-value
  (copy) semantics.

# Type declarations

Argument and return type declarations are required.

- **Type** = Scalar type (double, integer, or logical) and number of dimensions
- Sizes of each dimension can change.
- Static typing: a variable name cannot be re-used with a new type.

# Basics of generated C++

- Linear algebra (including simple vectorized math) is implemented via the Eigen library.
- *Everything has an interface*:

    - You can call any method of a `nimbleFunction` class.
    - You can access member data of `nimbleFunction` classes

# How to inspect or modify generated C++

Look in `tempdir()`, or tell `compileNimble` where to put the C++.


```r
timesScalarVector <- nimbleFunction(
    name = 'timesScalarVector', ## optional name used in C++
    run = function(a = double(0),  #0-dimensional double, aka scalar
                   x = double(1)   #1-dimensional double, aka vector
                   ) {
        ans <- a * x          # regular R math syntax
        return(ans)           # explicit return statement is required
        returnType(double(1)) #vector return type
        # returnType statement can appear anywhere in the function
    })
## Place the C++ code in the current directory
CtimesScalarVector <- compileNimble(timesScalarVector, dirName = '.')
```

```
## compiling... this may take a minute. Use 'showCompilerOutput = TRUE' to see C++ compiler details.
```

```
## compilation finished.
```

```r
## By default, C++ is written in the temporary directory that R
## creates for every session.  Its location can be found by
tempdir()
```

```
## [1] "/var/folders/v7/tzbf84253jg2_l2pm304l2cr0000gn/T//RtmpXR8EXi"
```

We can inspect the C++ header file,
[P\_1\_timesScalarVector.h](P_1_timesScalarVector.h), and the C++
implementation file,
[P\_1\_timesScalarVector.cpp](P_1_timesScalarVector.cpp).

# Upcoming features

- Automatic differentiation using the CppAD library.
- We have experimented with some use of Google's TensorFlow.

# A note on the future of the NIMBLE compiler and `nimbleFunctions`

- This has been a successful part of NIMBLE development in its own
right (aside from its original goal of model-generic programming).
- We aim to develop it more fully into a distinct programming tool.
- Changes will include:

    - Better type declaration system.
    - Clearer distinction of class vs. function programming.
	- More flexible use of native R object.
	- Other kinds of flexibility.

- We welcome contributors...
