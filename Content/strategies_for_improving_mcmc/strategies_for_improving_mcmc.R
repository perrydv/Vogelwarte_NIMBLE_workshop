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

## ----sigma-log-scale-----------------------------------------------------
assignRWlogScale <- function(MCMCconf, nodes) {
    for(node in nodes) {
        MCMCconf$removeSamplers(node)
        MCMCconf$addSampler(target = node,
                            type = 'RW',
                            control = list(log = TRUE))
    }
    MCMCconf
}
## Following is needed only when generating html
.GlobalEnv$assignRWlogScale <- assignRWlogScale


## ----add-sigma-log-scale-------------------------------------------------
addRWlogScale <- function(MCMCconf, nodes) {
    numSamplers <- length(MCMCconf$getSamplers())
    iHalf <- ceiling(numSamplers/2)
    for(node in nodes) {
        MCMCconf$addSampler(target = node,
                            type = 'RW',
                            control = list(log = TRUE))
    }
    ## re-order samplers so the new ones are in the middle of the list
    MCMCconf$setSamplers(c(1:iHalf, ## first half of original list
    (numSamplers+1):(numSamplers+length(nodes)), ## new samplers from end of list
    (iHalf+1):numSamplers)) ## second half of original list
    MCMCconf
}
.GlobalEnv$addRWlogScale <- addRWlogScale

## ----use-RW--------------------------------------------------------------
assignRW <- function(MCMCconf, model, nodes) {
    nodes <- model$expandNodeNames(nodes)
    for(node in nodes) {
        MCMCconf$removeSamplers(node)
        MCMCconf$addSampler(target = node,
                            type = 'RW')
    }
    MCMCconf
}
## Following is needed only when generating html
.GlobalEnv$assignRW <- assignRW


## ------------------------------------------------------------------------
blockStates <- function(MCMCconf, Rmodel, states, type) {
    stateNodes <- Rmodel$expandNodeNames(states)
    numStates <- length(stateNodes)
    numBlocks <- ceiling(numStates/3)
    for(i in 1:numBlocks) {
        iStart <- (3*(i-1)+1)       ## 1, 4, 7, 10 etc.
        iEnd <- min(3*i, numStates) ## 3, 6, 9, 12 etc. or max
        blockNodes <- stateNodes[iStart:iEnd]
        MCMCconf$removeSamplers(blockNodes)
        ## check if there is a singleton at the end
        if(iEnd > iStart) {
            MCMCconf$addSampler(blockNodes, type = type, silent = TRUE)
        } else {
            MCMCconf$addSampler(blockNodes, type = 'RW') ## in case there is a singleton
        }
    }
    MCMCconf
}

.GlobalEnv$blockStates <- blockStates

## ----compare-mcmcs-------------------------------------------------------
MCMCdefs = list(
    RWsigmaLogScale = quote({assignRWlogScale(configureMCMC(Rmodel),
                                         c('sigma.proc','sigma.obs'))}),
    RWsigmaLogScale2 = quote({addRWlogScale(assignRWlogScale(configureMCMC(Rmodel),
                                                        c('sigma.proc','sigma.obs')),
                                       c('sigma.proc','sigma.obs'))}),
    RWstates = quote({assignRW(configureMCMC(Rmodel),
                               Rmodel,
                               'logN.est')}),
    RWstates_RWsigmaLogScale = quote({assignRW(assignRWlogScale(configureMCMC(Rmodel),
                                                                c('sigma.proc','sigma.obs')),
                                               Rmodel,
                                               'logN.est')}),
    RWblockStates = quote({blockStates(configureMCMC(Rmodel),
                                       Rmodel,
                                       'logN.est',
                                       'RW_block')}),
    RWblockStates_RWsigmaLogScale = quote({blockStates(
                                               assignRWlogScale(configureMCMC(Rmodel),
                                                                c('sigma.proc','sigma.obs')),
                                               Rmodel,
                                               'logN.est',
                                               'RW_block')})
)

house_martin_comparisons <- compareMCMCs(
    list(house_martin = list(code = martin_code_alt,
                             inits = ourInits,
                             data = bugs.data)),
    niter = 50000,
    burnin = 5000,
    MCMCdefs = MCMCdefs,
    MCMCs = c('nimble', 'jags', names(MCMCdefs)),
    summary = TRUE)

make_MCMC_comparison_pages(house_martin_comparisons,
                           dir = "martin_MCMC_comparison_many",
                           modelNames = "house_martin")

