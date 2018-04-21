## ----setup, include=FALSE------------------------------------------------
library(methods) ## needed only when building documents outside of R
library(nimble)
library(mcmcplots)
if(!exists("nimble_course_dir")) ## set your own nimble_course_dir if needed
    nimble_course_dir <- file.path(getwd(),'..')
cur_dir <- getwd()
setwd(file.path(nimble_course_dir,
                 'examples_code',
                 'state_space_house_martins'))
source("state_space_house_martins_model.R")
setwd(cur_dir)

## ---- dependency-example-------------------------------------------------
martin_model$getDependencies('r[25]')

## ---- dep-24-------------------------------------------------------------
martin_model$getDependencies('r[24]')

## ---- dep-20-------------------------------------------------------------
martin_model$getDependencies('r[20]')

## ---- dep-1--------------------------------------------------------------
martin_model$getDependencies('r[1]')

## ------------------------------------------------------------------------
martin_code_alt <- nimbleCode({
# Priors and constraints
logN.est[1] ~ dnorm(5.6, 0.01)       # Prior for initial population size
mean.r ~ dnorm(1, 0.001)             # Prior for mean growth rate
sigma.proc ~ dunif(0, 1)          # Prior for sd of state process
sigma2.proc <- pow(sigma.proc, 2)
tau.proc <- pow(sigma.proc, -2)
sigma.obs ~ dunif(0, 1)           # Prior for sd of observation process
sigma2.obs <- pow(sigma.obs, 2)
tau.obs <- pow(sigma.obs, -2)

# Likelihood
# State process
for (t in 1:(T-1)) {
    logN.est[t+1] ~ dnorm(logN.est[t] + mean.r, tau.proc)
}

# Observation process
for (t in 1:T) {
    y[t] ~ dnorm(logN.est[t], tau.obs)
}

# Population sizes on real scale
for (t in 1:T) {
    N.est[t] <- exp(logN.est[t])
}
})

## ------------------------------------------------------------------------
martin_model_alt <- nimbleModel(martin_code_alt,
                                constants = bugs.data,
                                inits = martin_inits())
martin_model_alt$getDependencies('logN.est[20]')

## ------------------------------------------------------------------------
set.seed(1)
ourInits <- martin_inits()
mcmcResult <- compareMCMCs(
     list(original = list(code = martin_code, inits = ourInits, data = bugs.data)),
     niter = 50000, burnin = 5000, MCMCs = c('nimble','jags'), summary = TRUE)

mcmcResultAlt <- compareMCMCs(
     list(rewritten = list(code = martin_code_alt, inits = ourInits, data = bugs.data)),
     niter = 50000, burnin = 5000, MCMCs = c('nimble', 'jags'), summary = TRUE)

## Do some relabeling before combining results into one figure
mcmcResultAlt[[1]] <- rename_MCMC_comparison_method('nimble', 'nimble(alt)',
                                                    mcmcResultAlt[[1]])
mcmcResultAlt[[1]] <- rename_MCMC_comparison_method('jags', 'jags(alt)',
                                                    mcmcResultAlt[[1]])

mcmcBoth <- combine_MCMC_comparison_results(mcmcResult[[1]], mcmcResultAlt[[1]])

make_MCMC_comparison_pages(mcmcBoth, dir = 'martin_MCMC_comparison')

## ------------------------------------------------------------------------
configureAFSSsigmas <- function(Rmodel) {
    MCMCconf <- configureMCMC(Rmodel)
    MCMCconf$removeSamplers('sigma.proc')
    MCMCconf$removeSamplers('sigma.obs')
    MCMCconf$addSampler(target = c('sigma.proc','sigma.obs'),
                        type = 'AF_slice')
    MCMCconf
}

configureRWBsigmas <- function(Rmodel) {
    MCMCconf <- configureMCMC(Rmodel)
    MCMCconf$removeSamplers('sigma.proc')
    MCMCconf$removeSamplers('sigma.obs')
    MCMCconf$addSampler(target = c('sigma.proc','sigma.obs'),
                        type = 'RW_block')
    MCMCconf
}

## Next two lines are needed only when generating html
.GlobalEnv$configureAFSSsigmas <- configureAFSSsigmas
.GlobalEnv$configureRWBsigmas <- configureRWBsigmas

mcmcResultBlockSigmas <- compareMCMCs(
    list(original = list(code = martin_code_alt, inits = ourInits, data = bugs.data)),
    niter = 50000,
    burnin = 5000,
    MCMCdefs = list(
        AFSSsigmas = quote({configureAFSSsigmas(Rmodel)}),
        RWBsigmas = quote({configureRWBsigmas(Rmodel)})
    ),
    MCMCs = c('AFSSsigmas', 'RWBsigmas'),
    summary = TRUE)


