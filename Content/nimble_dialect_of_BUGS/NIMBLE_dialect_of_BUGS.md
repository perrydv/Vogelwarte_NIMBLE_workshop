---
title: "How NIMBLE's model language differs from BUGS and JAGS"
subtitle: "April 2018"
author: "Perry de Valpine, UC Berkeley"
output:
  html_document:
    code_folding: show
    toc: yes
---



# How NIMBLE is the same as BUGS and JAGS

* Most distributions and functions are supported

    - For distributions, see [User Manual Section 5.2.4](../NimbleUserManual.pdf#page=39)
    - For function, see  [User Manual Section 5.2.5](../NimbleUserManual.pdf#page=44)
	
* Most syntax is supported

    - Truncation syntax is different when using `nimbleCode`.  (It can
      be the same as for JAGS if reading code from a file with `readBUGSmodel`).

# How NIMBLE extends BUGS

  - Alternative distribution parameterizations (like R).
  - Named parameters (like R).
  - Vectorized math and linear algebra
  - Definition-time if-then-else (multiple model variants from the same code)
  - User-defined functions and distributions

### How NIMBLE is limited compared to BUGS and/or JAGS:

   - NIMBLE is stricter about requiring square brackets and
   informative indices for non-scalar nodes.

# R-like alternative and named parameters

Note named parameters in distributions


```r
pumpCode <- nimbleCode({ 
  for (i in 1:N){

      # likelihood (data model)
      x[i] ~ dpois(lambda = lambda[i])

      # latent process (random effects)
      # linear predictor      
      lambda[i] <- theta[i]*t[i]
      # random effects distribution
      theta[i] ~ dgamma(shape = alpha, rate = beta)
  }
  # priors on hyperparameters
  alpha ~ dexp(rate = 1.0)
  beta ~ dgamma(share = 0.1, rate = 1.0)
})
```

# Extensibility: new functions and distributions

We will cover this in depth later.

# Distinction between data and constants

- Constants must be provided to `nimbleModel`

    - Constants are values needed to define model relationships

        - Index ranges like `N`
        - Constant indexing vectors

- Data can be provided to `nimbleModel` or later

    - Data represents a flag on the role nodes play in the model

        - e.g. Data nodes shouldn't be sampled

    - Data values can be changed.

Example

```r
pump$isData('x')
```

```
##  [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
```

```r
pump$isData('lambda')
```

```
##  [1] FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE
```

```r
pump$x
```

```
##  [1]  5  1  5 14  3 19  1  1  4 22
```

```r
pump$x[3] <- 4
pump$x
```

```
##  [1]  5  1  4 14  3 19  1  1  4 22
```

```r
pump$simulate('x', includeData = TRUE)
pump$x
```

```
##  [1]  3  0  5 17  0  3  0  0  1  2
```

- NIMBLE will usually disambiguate data when it is provided as constants.

# More explicit need to provide dimensions

- Square brackets must always be provided to indicate number of dimensions

    - If `x` is 2-dimensional, use `x[,] %*% beta[]`, not `x %*% beta`
    
* Sometimes NIMBLE is not as smart as BUGS/JAGS at determining dimensions.  There are two solutions:

    * Give dimensions explicity: `x[1:n, 1:m]`, OR
    * Provide a `dimensions` argument to `nimbleModel`.  Example: `dimensions = list(x = c(n, m))`.

# Vectorized math and linear algebra

Instead of writing this in your model code:

```r
nimbleOptions(verbose = FALSE)
m1 <- nimbleModel(
    nimbleCode({
        for(i in 1:5) {
            predicted[i] <- beta0 + beta1 * x[i]
        }
    }
    ))
```
you can write this:

```r
m2 <- nimbleModel(
    nimbleCode({
        predicted[1:5] <- beta0 + beta1 * x[1:5]
    }
    ))
```

These are not equivalent:

```r
## m1 has 5 scalar nodes
m1$getNodeNames()
```

```
## [1] "predicted[1]" "predicted[2]" "predicted[3]" "predicted[4]"
## [5] "predicted[5]"
```

```r
## m2 has 1 vector node
m2$getNodeNames()
```

```
## [1] "predicted[1:5]"
```

One is not necessarily better than the other.  It depends on the model
and the MCMC configuration.  (More on those topics later.)

Vectorized declarations do not work for distributions.

Discussion topic for breaks:

- Would vectorized distribution declarations be helpful?
- How should they be defined?


# Definition-time if-then-else

If you wish to define multiple alternative models in one set of code,
you can use if-then-else statements.  These will be evaluated based on
variables in the R environment when the model is defined.  For
example:


```r
code <- nimbleCode({
    sigma ~ dunif(0, 10)
    beta0 ~ dnorm(0, sd = 1000)
    beta1 ~ dnorm(0, sd = 1000)
    if(INCLUDE_X2) {beta2 ~ dnorm(0, sd = 1000)} else{}
    for(i in 1:10) {
        if(INCLUDE_X2) {
            y[i] ~ dnorm(beta0 + beta1 * x1[i] + beta2 * x2[i], sd = sigma)
        } else {
            y[i] ~ dnorm(beta0 + beta1 * x1[i], sd = sigma)
        }
    }
})

INCLUDE_X2 <- FALSE
m1 <- nimbleModel(code)
INCLUDE_X2 <- TRUE
m2 <- nimbleModel(code)
m1$getNodeNames()
```

```
##  [1] "sigma"                                         
##  [2] "beta0"                                         
##  [3] "beta1"                                         
##  [4] "lifted_beta0_plus_beta1_times_x1_oBi_cB_L6[1]" 
##  [5] "lifted_beta0_plus_beta1_times_x1_oBi_cB_L6[2]" 
##  [6] "lifted_beta0_plus_beta1_times_x1_oBi_cB_L6[3]" 
##  [7] "lifted_beta0_plus_beta1_times_x1_oBi_cB_L6[4]" 
##  [8] "lifted_beta0_plus_beta1_times_x1_oBi_cB_L6[5]" 
##  [9] "lifted_beta0_plus_beta1_times_x1_oBi_cB_L6[6]" 
## [10] "lifted_beta0_plus_beta1_times_x1_oBi_cB_L6[7]" 
## [11] "lifted_beta0_plus_beta1_times_x1_oBi_cB_L6[8]" 
## [12] "lifted_beta0_plus_beta1_times_x1_oBi_cB_L6[9]" 
## [13] "lifted_beta0_plus_beta1_times_x1_oBi_cB_L6[10]"
## [14] "y[1]"                                          
## [15] "y[2]"                                          
## [16] "y[3]"                                          
## [17] "y[4]"                                          
## [18] "y[5]"                                          
## [19] "y[6]"                                          
## [20] "y[7]"                                          
## [21] "y[8]"                                          
## [22] "y[9]"                                          
## [23] "y[10]"
```

```r
m2$getNodeNames()
```

```
##  [1] "sigma"                                                                    
##  [2] "beta0"                                                                    
##  [3] "beta1"                                                                    
##  [4] "beta2"                                                                    
##  [5] "lifted_beta0_plus_beta1_times_x1_oBi_cB_plus_beta2_times_x2_oBi_cB_L8[1]" 
##  [6] "lifted_beta0_plus_beta1_times_x1_oBi_cB_plus_beta2_times_x2_oBi_cB_L8[2]" 
##  [7] "lifted_beta0_plus_beta1_times_x1_oBi_cB_plus_beta2_times_x2_oBi_cB_L8[3]" 
##  [8] "lifted_beta0_plus_beta1_times_x1_oBi_cB_plus_beta2_times_x2_oBi_cB_L8[4]" 
##  [9] "lifted_beta0_plus_beta1_times_x1_oBi_cB_plus_beta2_times_x2_oBi_cB_L8[5]" 
## [10] "lifted_beta0_plus_beta1_times_x1_oBi_cB_plus_beta2_times_x2_oBi_cB_L8[6]" 
## [11] "lifted_beta0_plus_beta1_times_x1_oBi_cB_plus_beta2_times_x2_oBi_cB_L8[7]" 
## [12] "lifted_beta0_plus_beta1_times_x1_oBi_cB_plus_beta2_times_x2_oBi_cB_L8[8]" 
## [13] "lifted_beta0_plus_beta1_times_x1_oBi_cB_plus_beta2_times_x2_oBi_cB_L8[9]" 
## [14] "lifted_beta0_plus_beta1_times_x1_oBi_cB_plus_beta2_times_x2_oBi_cB_L8[10]"
## [15] "y[1]"                                                                     
## [16] "y[2]"                                                                     
## [17] "y[3]"                                                                     
## [18] "y[4]"                                                                     
## [19] "y[5]"                                                                     
## [20] "y[6]"                                                                     
## [21] "y[7]"                                                                     
## [22] "y[8]"                                                                     
## [23] "y[9]"                                                                     
## [24] "y[10]"
```

m2 has `beta2` while m1 does not.  The long names are "lifted nodes"
-- more on those later.

Discussion topic for breaks:

- What would be a more useful system for writing model variants within
  one block of code?
