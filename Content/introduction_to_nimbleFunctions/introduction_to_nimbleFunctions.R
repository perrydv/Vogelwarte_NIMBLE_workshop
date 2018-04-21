## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)

## ----simple-nimbleFunction-----------------------------------------------
timesScalarVector <- nimbleFunction(
    run = function(a = double(0),  #0-dimensional double, aka scalar
                   x = double(1)   #1-dimensional double, aka vector
                   ) {
        ans <- a * x          # regular R math syntax
        return(ans)           # explicit return statement is required
        returnType(double(1)) #vector return type
        # returnType statement can appear anywhere in the function
    })

## ----simple-uncompiled---------------------------------------------------
a <- 2
x <- rnorm(10000)
y <- timesScalarVector(a, x)
head(y)

## ----simple-compiled-----------------------------------------------------
CtimesScalarVector <- compileNimble(timesScalarVector)
Cy <- CtimesScalarVector(a, x)
head(Cy)
identical(y, Cy)

## ----mult-cumsum---------------------------------------------------------
set.seed(1)
multCumsum <- function(x, y) {
    return(x * cumsum(y))
}
x <- seq(.1, 1.0, by = .1)
y <- 1:10
x
y
cumsum(y)
multCumsum(x, y)
## To use it with a new x, cumsum(y) is wastefully recomputed internally
x2 <- seq(.01, .1, by = .01)
multCumsum(x2, y)

## ----mult-cumsumNF-------------------------------------------------------
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

## ----use-mult-cumsumNF---------------------------------------------------
multCumsumNF_y <- multCumsumNF(y) ## calls setup function
## returns an object with a run method
multCumsumNF_y$run(x)
## Now we can use it with the new x2 and the old y, which is "baked in"
multCumsumNF_y$run(x2)

## ----mult-cumsumNF-compile-----------------------------------------------
CmultCumsumNF_y <- compileNimble(multCumsumNF_y)
CmultCumsumNF_y$run(x)  ## This calls compiled C++
CmultCumsumNF_y$run(x2)

## ----mult-cumsumNF-new---------------------------------------------------
y2 <- seq(10, 100, by = 10)
multCumsumNF_y2 <- multCumsumNF(y2)
CmultCumsumNF_y2 <- compileNimble(multCumsumNF_y2, project = multCumsumNF_y)
CmultCumsumNF_y2$run(x)
CmultCumsumNF_y2$run(x2)

