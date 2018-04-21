## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)
if(!exists("nimble_course_dir")) ## set your own nimble_course_dir if needed
    nimble_course_dir <- file.path(getwd(),'..')
source(file.path(nimble_course_dir,
                 'examples_code',
                 'pump',
                 'pump_model.R'))

## ---- pump-model---------------------------------------------------------

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


## ---- data-example-------------------------------------------------------
pump$isData('x')
pump$isData('lambda')
pump$x
pump$x[3] <- 4
pump$x
pump$simulate('x', includeData = TRUE)
pump$x

## ---- vectorized-1-------------------------------------------------------
nimbleOptions(verbose = FALSE)
m1 <- nimbleModel(
    nimbleCode({
        for(i in 1:5) {
            predicted[i] <- beta0 + beta1 * x[i]
        }
    }
    ))

## ---- vectorized-2-------------------------------------------------------
m2 <- nimbleModel(
    nimbleCode({
        predicted[1:5] <- beta0 + beta1 * x[1:5]
    }
    ))

## ---- vectorized-3-------------------------------------------------------
## m1 has 5 scalar nodes
m1$getNodeNames()
## m2 has 1 vector node
m2$getNodeNames()

## ----if-then-else--------------------------------------------------------
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
m2$getNodeNames()


