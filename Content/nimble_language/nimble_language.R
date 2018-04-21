## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)

## ----numeric-r-----------------------------------------------------------
args(numeric)
numeric(5)

## ----numeric-nimble------------------------------------------------------
args(nimNumeric)
nimNumeric(length = 5, value = c(1, 2))
nimNumeric(length = 5, value = c(1, 2), recycle = FALSE, fillZeros = TRUE)

## ----numeric-nimble2-----------------------------------------------------
nimNumeric(length = 5, init = FALSE) ## still gets zeros in uncompiled mode

## ----numeric-NF----------------------------------------------------------
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
CnumericDemo <- compileNimble(numericDemo)
CnumericDemo()

## ----matrix-array--------------------------------------------------------
args(nimMatrix)
args(nimArray)

## ----matrix-mult-example-------------------------------------------------
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
matrixMult(A, x)

## ----compile-matrix-mult-------------------------------------------------
CmatrixMult <- try(compileNimble(matrixMult))
CmatrixMult

## ----harder-error--------------------------------------------------------
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
CmatrixMult2 <- try(compileNimble(matrixMult2))
CmatrixMult2

