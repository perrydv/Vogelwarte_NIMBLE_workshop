## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)
library(mcmcplots)

## ----model-code----------------------------------------------------------
library(nimble)
pumpCode <- nimbleCode({ 
  for (i in 1:N){

      # likelihood (data model)
      x[i] ~ dpois(lambda[i])

      # latent process (random effects)
      # linear predictor      
      lambda[i] <- theta[i]*t[i]
      # random effects distribution
      theta[i] ~ dgamma(alpha,beta)
  }
  # priors on hyperparameters
  alpha ~ dexp(1.0)
  beta ~ dgamma(0.1,1.0)
})

## ----build-model---------------------------------------------------------
N <- 10
t <- c(94.3, 15.7, 62.9, 126, 5.24, 31.4, 1.05, 1.05, 2.1, 10.5)
x <- c(5, 1, 5, 14, 3, 19, 1, 1, 4, 22)
pumpConsts <- list(t = t, N = 10)
pumpData <- list(x = x)
pumpInits <- list(alpha = 1,
                  beta = 1,
                  theta = rep(0.1, pumpConsts$N))
pump <- nimbleModel(pumpCode, 
                    data = pumpData,
                    constants = pumpConsts,
                    inits = pumpInits)

## ----use-pump------------------------------------------------------------
pump$getNodeNames()
pump$theta

## ---- compile-model------------------------------------------------------
Cpump <- compileNimble(pump)

## ----use-compiled-model--------------------------------------------------
Cpump$theta

## ---- conf---------------------------------------------------------------
pumpConf <- configureMCMC(pump)
pumpMCMC <- buildMCMC(pumpConf)

## ---- conf2--------------------------------------------------------------
pumpMCMC <- buildMCMC(pump)

## ---- compile------------------------------------------------------------
CpumpMCMC <- compileNimble(pumpMCMC, project = pump)

## ---- run----------------------------------------------------------------
samples <- runMCMC(CpumpMCMC, niter = 1000)

## ---- plot-samples-------------------------------------------------------
dir.create("pump_samples", showWarnings = FALSE)
mcmcplot(samples, dir = "pump_samples")

