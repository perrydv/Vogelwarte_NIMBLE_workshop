## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)

## ----tempdir-------------------------------------------------------------
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
## By default, C++ is written in the temporary directory that R
## creates for every session.  Its location can be found by
tempdir()

