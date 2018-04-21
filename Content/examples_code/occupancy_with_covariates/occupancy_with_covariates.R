# Modified from AHM Chapter 10, section 10.4,
# by Jacob Levine and Perry de Valpine
#
source("occupancy_with_covariates_setup.R")

library(nimble)
# Specify model in BUGS language
# "model.txt" in book code
Section10p4_code <- nimbleCode({
    
    # Priors
    mean.p ~ dunif(0, 1)         # Detection intercept on prob. scale
    alpha0 <- logit(mean.p)      # Detection intercept
    alpha1 ~ dunif(-20, 20)      # Detection slope on wind
    mean.psi ~ dunif(0, 1)       # Occupancy intercept on prob. scale
    beta0 <- logit(mean.psi)     # Occupancy intercept
    beta1 ~ dunif(-20, 20)       # Occupancy slope on vegHt
    
    # Likelihood
    for (i in 1:M) {
      # True state model for the partially observed true state
      z[i] ~ dbern(psi[i])      # True occupancy z at site i
      logit(psi[i]) <- beta0 + beta1 * vegHt[i]
      for (j in 1:J) {
        # Observation model for the actual observations
        y[i,j] ~ dbern(p.eff[i,j])    # Detection-nondetection at i and j
        p.eff[i,j] <- z[i] * p[i,j]   # 'straw man' for WinBUGS
        logit(p[i,j]) <- alpha0 + alpha1 * wind[i,j]
      }
    }
    
    # Derived quantities
    N.occ <- sum(z[1:M])       # Number of occupied sites among sample of M
    psi.fs <- N.occ/M       # Proportion of occupied sites among sample of M
    for(k in 1:100){
        logit(psi.pred[k]) <- beta0 + beta1 * XvegHt[k] # psi predictions
        logit(p.pred[k]) <- alpha0 + alpha1 * Xwind[k]  # p predictions
    }
  }
)

Section10p4_noDerived_code <- nimbleCode({
    
    # Priors
    mean.p ~ dunif(0, 1)         # Detection intercept on prob. scale
    alpha0 <- logit(mean.p)      # Detection intercept
    alpha1 ~ dunif(-20, 20)      # Detection slope on wind
    mean.psi ~ dunif(0, 1)       # Occupancy intercept on prob. scale
    beta0 <- logit(mean.psi)     # Occupancy intercept
    beta1 ~ dunif(-20, 20)       # Occupancy slope on vegHt
    
    # Likelihood
    for (i in 1:M) {
      # True state model for the partially observed true state
      z[i] ~ dbern(psi[i])      # True occupancy z at site i
      logit(psi[i]) <- beta0 + beta1 * vegHt[i]
      for (j in 1:J) {
        # Observation model for the actual observations
        y[i,j] ~ dbern(p.eff[i,j])    # Detection-nondetection at i and j
        p.eff[i,j] <- z[i] * p[i,j]   # 'straw man' for WinBUGS
        logit(p[i,j]) <- alpha0 + alpha1 * wind[i,j]
      }
    }
    
    # Derived quantities
    ## N.occ <- sum(z[1:M])       # Number of occupied sites among sample of M
    ## psi.fs <- N.occ/M       # Proportion of occupied sites among sample of M
    ## for(k in 1:100){
    ##     logit(psi.pred[k]) <- beta0 + beta1 * XvegHt[k] # psi predictions
    ##     logit(p.pred[k]) <- alpha0 + alpha1 * Xwind[k]  # p predictions
    ## }
  }
)


## # Parameters monitored
## params <- c("alpha0", "alpha1", "beta0", "beta1", "N.occ", "psi.fs", "psi.pred", "p.pred", "z") # Also estimate z = "conditional occ. prob."
## params_of_interest <- c("alpha0", "alpha1", "beta0", "beta1", "N.occ", "psi.fs")

## # MCMC settings
## ni <- 25000   ;   nt <- 10   ;   nb <- 2000   ;   nc <- 3

## occ_model <- nimbleModel(Section10p4_code,
##                          constants = win.data,
##                          inits = inits())


## Section10p4_compare <- compareMCMCs(
##   modelInfo = list(
##     code = Section10p4_code,
##     data = win.data,
##     inits = inits()
##   ),
##   ## making the comparison for all latent states in params would be cumbersome
##   monitors = params_of_interest,
##   MCMCs = c('nimble', 'jags'),
##   summary = FALSE,
##   burnin = nb,
##   niter = ni
## )

## make_MCMC_comparison_pages(Section10p4_compare, modelNames = "Section10p4", dir = outputDirectory)

## browseURL(file.path(outputDirectory, "Section10p4.html"))
